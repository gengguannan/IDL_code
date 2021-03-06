;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;define the function of the form F(x)=a+b*x+c*sin(d*x+e)
;a and d is known                                       
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pro gfunct, X, A, F, pder

ax = sin( 0.5236 * X + A[2] )
bx = cos( 0.5236 * X + A[2] )
F = A[0] * X + A[1] * ax

;If the procedure is called with 4 parameters, calculate the partial derivatives
if n_params() ge 4 then $
  pder= [[X], [ax], [A[1] * bx]]

end


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;Compute the fit to the function we have just defined
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pro trend_analysis_by_area

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

InType = CTM_Type( 'GENERIC', Resolution=[0.25d0,0.25d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

limit=[15,70,55,136]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
I0 = ( 70 + 180 ) / 0.25
J0 = ( 15 + 90 ) / 0.25
print,I1,I2,J1,J2


;prepare the data needed
;filename1 = '/z3/wangsiwen/Satellite/no2/GOME_KNMI_v2.0/no2_199604.bpch'
filename1 = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_KNMI_v2.0/no2_200301.bpch'

ctm_get_data,datainfo1,filename = filename1,tracer=1
intercept=*(datainfo1[0].data)


xx = I2 - I1 + 1
yy = J2 - J1 + 1
zz = (2011-2003+1)*12

no2 = fltarr(xx,yy,zz)
data = fltarr(xx,yy,zz)

for y = 2003,2011 do begin
for m = 1,12 do begin

k = m+(y-2003)*12-1

Yr4  = String( y, format = '(i4.4)' )
Mon2 = String( m, format = '(i2.2)' )

nymd = y * 10000L + m * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd


if nymd eq 19960101 then continue
if nymd eq 19960201 then continue
if nymd eq 19960301 then continue

;filename2 = '/z3/wangsiwen/Satellite/no2/GOME_KNMI_v2.0/no2_'+ Yr4 + Mon2 +'.bpch'
filename2 = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_KNMI_v2.0/no2_'+ Yr4 + Mon2 +'.bpch'

ctm_get_data,datainfo2,filename = filename2,tracer=1
data18=*(datainfo2[0].data)

filename3 = '/home/gengguannan/indir/total_popu_025x025.bpch'

ctm_get_data,datainfo3,filename = filename3
popu=*(datainfo3[0].data)

filename4 = '/home/gengguannan/indir/area_mask_1_025x025.bpch'

ctm_get_data,datainfo4,filename = filename4
mask=*(datainfo4[0].data)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    no2[I-I0,J-J0,k] = data18[I,J]
    data[I-I0,J-J0,k] = data18[I,J]-intercept[I,J]
  endfor
endfor

CTM_CLEANUP

endfor
endfor

area = [22,113.25,23,114.25]

i1_index = where(xmid ge area[1] and xmid le area[3])
j1_index = where(ymid ge area[0] and ymid le area[2])
II1 = min(i1_index, max = II2)
JJ1 = min(j1_index, max = JJ2)


for I = II1,II2 do begin
for J = JJ1,JJ2 do begin
mask[I,J] = 8
endfor
endfor

for l = 1,8 do begin

avg = make_array(zz)
avg_no2 = make_array(zz)
nod = make_array(zz)


;averaged by province
for I = 0,xx-1 do begin
  for J = 0,yy-1 do begin
    for p = 0,zz-1 do begin

      if popu[I+I0,J+J0] gt 0 and mask[I+I0,J+J0] eq l and no2[I,J,p] gt 0 then begin
        avg[p]+= data[I,J,p]
        avg_no2[p]+= no2[I,J,p]
        nod[p]+= 1
      endif

    endfor
  endfor
endfor


for p = 0,zz-1 do begin
  if nod[p] gt 0 then begin
    avg[p] = avg[p]/nod[p]
    avg_no2[p] = avg_no2[p]/nod[p]
  endif
endfor


;grids included in each area
grid = 0

for I = 0,xx-1 do begin
  for J = 0,yy-1 do begin
    if popu[I+I0,J+J0] gt 0 and mask[I+I0,J+J0] eq l then begin
      grid += 1
    endif
  endfor
endfor

print,'GRIDS',grid


;reference year
ref = 0
nod = 0

for q = 0,11 do begin
  if avg_no2[q] gt 0 then begin
    ref += avg_no2[q]
    nod += 1
  endif
endfor

ref = ref/nod

print,'reference year',ref,nod


;data for trend analysis
X0 = indgen(zz)+1
X1 = make_array(1)
Y1 = make_array(1)
flag = 1

for p = 0,zz-1 do begin

  if avg[p] gt 0 then begin
    if flag eq 1 then begin
      Y1 = [avg[p]]
      X1 = [X0[p]]
    endif else begin
      Y1 = [Y1,avg[p]]
      X1 = [X1,X0[p]]
    endelse
    flag = 0
  endif

endfor


;fit
weights = make_array(n_elements(X1),value=1.0)

A = [0.0025,3,1.5708];Provide an initial guess of the function's parameters

yfit = CURVEFIT(X1,Y1,weights,A,SIGMA,FUNCTION_NAME='gfunct',ITMAX=50);Compute the parameters

print, 'Function parameters: ', A


; validate
res = A[0] * X1 + A[1] * sin( 0.5236 * X1 + A[2] ) - Y1

lag = [1]

cor = A_CORRELATE(res,lag,/DOUBLE)
;print, cor

var = VARIANCE(res)
;print, var

n = zz
;print, n, n_elements(X1)

sd = var / (n^(1.5)) * ((1+cor[0])/(1-cor[0]))^(0.5)
;print, sd

print,ABS(A[0]/sd)

endfor

end
