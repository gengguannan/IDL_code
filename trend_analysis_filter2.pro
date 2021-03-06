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
pro trend_analysis_filter2

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

InType = CTM_Type( 'GENERIC', Resolution=[1d0,1d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

limit=[15,70,55,136]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
I0 = ( 70 + 180 ) / 1
J0 = ( 15 + 90 ) / 1
print,I1,I2,J1,J2


;prepare the data needed
filename1 = '/z3/gengguannan/satellite/no2/GOME_Bremen/gome_no2_v3-0_199604_1x1.bpch'
;filename1 = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_200301.bpch'

ctm_get_data,datainfo1,filename = filename1,tracer=1
intercept=*(datainfo1[0].data)


xx = I2 - I1 + 1
yy = J2 - J1 + 1
zz = (2010-1996+1)*12-4

no2 = fltarr(xx,yy,zz)
data = fltarr(xx,yy,zz)
mask2 = fltarr(InGrid.IMX,InGrid.JMX)
slope = fltarr(InGrid.IMX,InGrid.JMX)

for y = 1996,2010 do begin
for m = 1,12 do begin

k = m+(y-1996)*12-5

Yr4  = String( y, format = '(i4.4)' )
Mon2 = String( m, format = '(i2.2)' )

nymd = y * 10000L + m * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd


if nymd eq 19960101 then continue
if nymd eq 19960201 then continue
if nymd eq 19960301 then continue
if nymd eq 19960401 then continue


if y lt 2003 $
  then filename2 = '/z3/gengguannan/satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 + Mon2 +'_1x1.bpch' $
  else filename2 = '/z3/gengguannan/satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 + Mon2 +'_1x1.bpch'

ctm_get_data,datainfo2,filename = filename2,tau0=nymd2tau(NYMD),tracer=1
data18=*(datainfo2[0].data)

filename3 = '/home/gengguannan/result/trend_analysis_mask1_1x1.bpch'

ctm_get_data,datainfo3,filename = filename3
mask1=*(datainfo3[0].data)


for I = I1,I2 do begin
  for J = J1,J2 do begin
    no2[I-I0,J-J0,k] = data18[I,J]
    data[I-I0,J-J0,k] = data18[I,J]-intercept[I,J]
  endfor
endfor

CTM_CLEANUP

endfor
endfor


;fit
for I = 0,xx-1 do begin
  for J = 0,yy-1 do begin

    X0 = indgen(zz)+1
    X1 = make_array(1)
    Y1 = make_array(1)
    Y0 = make_array(1)
    flag = 1

    if mask1[I+I0,J+J0] gt 0 then begin

      for p = 0,zz-1 do begin

        if no2[I,J,p] gt 0 then begin
          if flag eq 1 then begin
            Y1 = [data[I,J,p]]
            X1 = [X0[p]]
          endif else begin
            Y1 = [Y1,data[I,J,p]]
            X1 = [X1,X0[p]]
          endelse
          flag = 0
        endif

      endfor

      weights = make_array(n_elements(X1),value=1.0)

      ; Provide an initial guess of the function's parameters
      A = [0.0025,3,1.5708]

      ; Compute the parameters.
      yfit = CURVEFIT(X1,Y1,weights,A,SIGMA,FUNCTION_NAME='gfunct',ITMAX=50)

      ; Print the parameters returned in A.
      print, 'Function parameters: ', A

      ; validate
      res = A[0] * X1 + A[1] * sin( 0.5236 * X1 + A[2] ) - Y1

      lag = [1]

      cor = A_CORRELATE(res,lag,/DOUBLE)
      print, cor

      var = VARIANCE(res)
      print, var

      n = zz
      print, n, n_elements(X1)

      sd = var / (n^(1.5)) * ((1+cor[0])/(1-cor[0]))^(0.5)
      print, sd

      print,ABS(A[0]/sd)

      if ABS(A[0]/sd) gt 2 then begin
        mask2[I+I0,J+J0] = 1
        slope[I+I0,J+J0] = A[0]*12
      endif else begin
        mask2[I+I0,J+J0] = 0
        slope[I+I0,J+J0] = -999
      endelse

    endif else begin
      slope[I+I0,J+J0] = -999
    endelse

    CTM_CLEANUP

  endfor
endfor

print,total(mask2)

outfile1 = '/home/gengguannan/result/trend_analysis_mask2_1x1.bpch'
outfile2 = '/home/gengguannan/result/trend_analysis_slope_1x1.bpch'

  ; Make a DATAINFO structure
   success = CTM_Make_DataInfo( mask2,                   $
                                ThisDataInfo,            $
                                ThisFileInfo,            $
                                ModelInfo=InType,        $
                                GridInfo=InGrid,         $
                                DiagN='LANDMAP',         $
                                Tracer=802,              $
                                Tau0= nymd2tau(19850101),$
                                Unit='unitless',         $
                                Dim=[InGrid.IMX, InGrid.JMX, 0, 0],      $
                                First=[1L, 1L, 1L],      $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = outfile1

   success = CTM_Make_DataInfo( slope,                   $
                                ThisDataInfo,            $
                                ThisFileInfo,            $
                                ModelInfo=InType,        $
                                GridInfo=InGrid,         $
                                DiagN='LANDMAP',         $
                                Tracer=802,              $
                                Tau0= nymd2tau(19850101),$
                                Unit='unitless',         $
                                Dim=[InGrid.IMX, InGrid.JMX, 0, 0],      $
                                First=[1L, 1L, 1L],      $
                                /No_vertical )
   CTM_WriteBpch, ThisDataInfo, FileName = outfile2

end
