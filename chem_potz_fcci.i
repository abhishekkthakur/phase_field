#
# This test is for the 3-phase KKS model
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 25
  ny = 25
  nz = 0
  xmin = -5
  xmax = 5
  ymin = -5
  ymax = 5
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

[AuxVariables]
  [./Energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  # Global concentrations
  [./xAs]
    order = FIRST
    family = LAGRANGE
  [../]
  [./xNd]
    order = FIRST
    family = LAGRANGE
  [../]
  # order parameter 1
  [./eta1]
    order = FIRST
    family = LAGRANGE
  [../]
  # order parameter 2
  [./eta2]
    order = FIRST
    family = LAGRANGE
    #initial_condition = 0.0
  [../]
  # order parameter 3
  [./eta3]
    order = FIRST
    family = LAGRANGE
  [../]
  # Local phase concentration 1
  [./xAs1]
    order = FIRST
    family = LAGRANGE
    #initial_condition = 0
  [../]
  [./xNd1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
  [../]
  # Local phase concentration 2
  [./xAs2]
    order = FIRST
    family = LAGRANGE
    #initial_condition = 0.5
  [../]
  [./xNd2]
    order = FIRST
    family = LAGRANGE
    #initial_condition = 0.5
  [../]
  # Local phase concentration 3
  [./xAs3]
    order = FIRST
    family = LAGRANGE
    #initial_condition = 0.5
  [../]
  [./xNd3]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.5
  [../]
  # Lagrange multiplier
  [./lambda]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]
[]

[Functions]
  [./ic_func_eta_left]
    type = ParsedFunction
    value = 0.5*(1.0-tanh(2*x/sqrt(2.0)))
  [../]
  [./ic_func_eta_right]
    type = ParsedFunction
    value = 0.5*(1.0-tanh(-2*x/sqrt(2.0)))
  [../]
  [./ic_func_c]
    type = ParsedFunction
    value = 0.25*(1.0-tanh(2*x/sqrt(2.0)))
  [../]
[]

[ICs]
  [./eta1]
    variable = eta1
    type = FunctionIC
    function = ic_func_eta_left
    #type = RandomIC
    #min = 0.1
    #max = 0.9
  [../]
  [./eta2]
    variable = eta2
    type = FunctionIC
    function = 0
  [../]
  [./eta3]
    variable = eta3
    type = FunctionIC
    function = ic_func_eta_right
    #type = RandomIC
    #min = 0.1
    #max = 0.9
  [../]
  [./xAs]
    variable = xAs
    type = FunctionIC
    function = ic_func_c
    #type = RandomIC
    #min = 0
    #max = 0.5
  [../]
  [./xNd]
    variable = xNd
    type = FunctionIC
    function = 0
    #type = RandomIC
    #min = 0.2
    #max = 0.5
  [../]
  [./xAs1]
    variable = xAs1
    type = RandomIC
    min = 0.1
    max = 0.9
  [../]
  [./xAs3]
    variable = xAs3
    type = RandomIC
    min = 0.1
    max = 0.9
  [../]
[]


[Materials]
  # simple toy free energies
  [./f1]
    type = DerivativeParsedMaterial
    f_name = F1
    args = 'xNd1 xAs1'
    constant_names = 'dEAsAs_p1 dENdNd_p1 dENdAs_p1 L0UNd_p1 L0NdAs_p1 L0UAs_p1'
    constant_expressions = '-1.44 3.84 -3.225 4.17 -3.225 -1.04'
    # function = 'xU1:=1-xAs1-xNd1; xU1*-0.15608 + 50*xAs1^2 + 50*xNd1^2'
    function = 'xU1:=1-xNd1-xAs1; xU1*-0.15608 + xNd1*0.05182 + xAs1*0.05182 + 3*xNd1*xNd1*3.84
                + 8.617e-05*300*(xU1*plog(xU1,0.1) + xNd1*plog(xNd1,0.0001) + xAs1*plog(xAs1,0.0001))
                + xU1*xNd1*L0UNd_p1'
                #+ 3*xNd1*xNd1*dENdNd_p1
    outputs = exodus
  [../]
  [./f2]
    type = DerivativeParsedMaterial
    f_name = F2
    args = 'xNd2 xAs2'
    constant_names = 'dENdAs factor1 L0UNd_p2 L0UAs_p2 L0NdAs_p2'
    constant_expressions = '-1.57 200 1.01 11.38 16.65'
    function = 'xU2:=1-xNd2-xAs2; 0.5*-0.21585 + 0.5*-0.263903 + dENdAs
                + factor1*((xNd2-0.5)^2 + (xAs2-0.5)^2)
                + 0
                + 0'
    outputs = exodus
  [../]
  [./f3]
    type = DerivativeParsedMaterial
    f_name = F3
    args = 'xNd3 xAs3'
    constant_names = 'factor2 L0UNd_p3 L0NdAs_p3 L0UAs_p3'
    constant_expressions = '100 -1.46 3.60 3.52'
    function = 'xU3:=1-xNd3-xAs3; 0.5*-0.08724 + 0.5*-0.26 + -1.03
                + factor2*((0.5-xNd3-xAs3)*(0.5-xNd3-xAs3) + (xAs3-0.5)*(xAs3-0.5))
                + 0
                + 0'
    outputs = exodus
  [../]
[../]

#[AuxKernels]
#  [./Energy_total]
#    type = KKSMultiFreeEnergy
#    Fj_names = 'F1 F2 F3'
#    hj_names = 'h1 h2 h3'
#    gj_names = 'g1 g2 g3'
#    variable = Energy
#    w = 1.35
#    interfacial_vars =  'eta1  eta2  eta3'
#    kappa_names =       'kappa kappa kappa'
#  [../]
#[]

[Executioner]
  type = Transient
  solve_type = NEWTON #'PJFNK'
  # petsc_options_iname = '-pc_type -sub_pc_type   -sub_pc_factor_shift_type'
  # petsc_options_value = 'asm       ilu            nonzero'
  petsc_options_iname = '-pc_type  -pc_factor_shift_type'
  petsc_options_value = 'lu        nonzero'
  l_max_its = 100
  nl_max_its = 1000
  l_tol = 1.0e-8
  nl_rel_tol = 1.0e-9
  nl_abs_tol = 1.0e-9
  end_time = 1e10

  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    iteration_window = 2
    growth_factor = 1.5
    #dt = 1e-5
    dt = 1e-2
  [../]
  [./Predictor]
    type = SimplePredictor
    scale = 0.5
  [../]

[]

[Preconditioning]
  active = 'full'
  [./full]
    type = SMP
    full = true
  [../]
  [./mydebug]
    type = FDP
    full = true
  [../]
[]

#[Postprocessors]
#  [./XNd]
#    type = ElementAverageValue
#    variable = xNd
#  [../]
#  [./XAs]
#    type = ElementAverageValue
#    variable = xAs
#  [../]
#  [./Ftotal]
#    type = ElementIntegralVariablePostprocessor
#    variable = Energy
#  [../]
#[]

[Outputs]
  exodus = true
  csv = true
[]
