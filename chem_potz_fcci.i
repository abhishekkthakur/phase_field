#
# This test is for the 3-phase KKS model
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 25
  ny = 25
  nz = 0
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

[AuxVariables]
  [./T]
    [./InitialCondition]
      type = FunctionIC
      function = y*1200+300
    [../]
  [../]
  # Local phase concentration 1
  [./xAs1]
    initial_condition = 0.5
  [../]
  [./xNd1]
    [./InitialCondition]
      type = FunctionIC
      function = x*0.5
    [../]
  [../]
  # Local phase concentration 2
  [./xAs2]
    initial_condition = 0.5
  [../]
  [./xNd2]
    [./InitialCondition]
      type = FunctionIC
      function = x*0.5
    [../]
  [../]
  # Local phase concentration 3
  [./xAs3]
    initial_condition = 0.5
  [../]
  [./xNd3]
    [./InitialCondition]
      type = FunctionIC
      function = x*0.5
    [../]
  [../]
[]

[Materials]
  [./f1]
    type = DerivativeParsedMaterial
    derivative_order = 1
    f_name = F1
    args = 'xNd1 xAs1 T'
    constant_names = 'dEAsAs_p1 dENdNd_p1 dENdAs_p1 L0UNd_p1 L0NdAs_p1 L0UAs_p1 JtoeV'
    constant_expressions = '-1.44 3.84 -3.225 4.17 -3.225 -1.04 96488'
    function = 'G0U:=(-8407.734 + 130.955151*T - 26.9182*T*log(T) + 1.25156e-03*T^2 - 4.42605e-06*T^3 + 38568/T)/JtoeV;
                G0Nd:=1;
                G0As:=0.05182;
                xU1:=1-xNd1-xAs1; xU1*G0U + xNd1*G0Nd + xAs1*G0As + 3*xNd1*xNd1*3.84
                + 8.617e-05*300*(xU1*plog(xU1,0.1) + xNd1*plog(xNd1,0.0001) + xAs1*plog(xAs1,0.0001))
                + xU1*xNd1*L0UNd_p1'
                #+ 3*xNd1*xNd1*dENdNd_p1
    outputs = exodus
    output_properties = dF1/dxNd1
  [../]
  [./f2]
    type = DerivativeParsedMaterial
    derivative_order = 1
    f_name = F2
    args = 'xNd2 xAs2 T'
    constant_names = 'dENdAs factor1 L0UNd_p2 L0UAs_p2 L0NdAs_p2 JtoeV'
    constant_expressions = '-1.57 200 1.01 11.38 16.65 96488'
    function = 'G0Nd:=(-7902.93 + 111.10239*T - 27.0858*T*log(T) + 0.556125e-03 * T^2 - 2.6923e-06 * T^3 + 34887/T)/JtoeV;
                G0As:=(17603.553 + 107.471069*T - 23.3144*T*log(T) - 2.71613e-03 * T^2 + 11600/T)/JtoeV;
                xU2:=1-xNd2-xAs2; 0.5*G0Nd + 0.5*G0As + dENdAs
                + factor1*((xNd2-0.5)^2 + (xAs2-0.5)^2)
                + 0
                + 0'
    outputs = exodus
    output_properties = dF2/dxNd2
  [../]
  [./f3]
    type = DerivativeParsedMaterial
    derivative_order = 1
    f_name = F3
    args = 'xNd3 xAs3 T'
    constant_names = 'factor2 L0UNd_p3 L0NdAs_p3 L0UAs_p3 JtoeV'
    constant_expressions = '100 -1.46 3.60 3.52 96488'
    function = 'G0U:=(-752.767 + 131.5381*T -27.5152*T*log(T) - 8.35595e-03 * T^2 + 0.967907e-06 * T^3 + 204611/T)/JtoeV;
                G0As:=(17603.553 + 106.111069*T - 23.3144*T*log(T) - 2.71613e-03 * T^2 + 11600/T)/JtoeV;
                xU3:=1-xNd3-xAs3; 0.5*G0U + 0.5*G0As + -1.03
                + factor2*((0.5-xNd3-xAs3)*(0.5-xNd3-xAs3) + (xAs3-0.5)*(xAs3-0.5))
                + 0
                + 0'
    outputs = exodus
    output_properties = dF3/dxNd3
  [../]
[../]

[Executioner]
  type = Transient
  num_steps = 1
[]

[Problem]
  kernel_coverage_check = false
  solve = false
[]

[Outputs]
  exodus = true
[]
