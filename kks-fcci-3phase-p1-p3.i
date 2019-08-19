#
# This test is for the 3-phase KKS model
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  #nx = 100
  #ny = 2
  nx = 100
  ny = 1
  nz = 0
  xmin = -10
  xmax = 10
  #ymin = 0
  #ymax = 2
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

[AuxVariables]
  [./Energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Variables]
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
    #args = 'c1'
    #function = '20*(c1-0.2)^2'
    args = 'xNd1 xAs1'
    constant_names = 'dEAsAs_p1 dENdNd_p1 dENdAs_p1 L0UNd_p1 L0NdAs_p1 L0UAs_p1'
    constant_expressions = '-1.44 3.84 -3.225 4.17 -3.225 -1.04'
    # function = 'xU1:=1-xAs1-xNd1; xU1*-0.15608 + 50*xAs1^2 + 50*xNd1^2'
    function = 'xU1:=1-xNd1-xAs1; xU1*-0.15608 + xNd1*0.05182 + xAs1*0.05182 + 3*xNd1*xNd1*3.84
                + 8.617e-05*300*(xU1*plog(xU1,0.1) + xNd1*plog(xNd1,0.0001) + xAs1*plog(xAs1,0.0001))
                + xU1*xNd1*L0UNd_p1'
                #+ 3*xNd1*xNd1*dENdNd_p1
  [../]
  [./f2]
    type = DerivativeParsedMaterial
    f_name = F2
    #args = 'c2'
    #function = '20*(c2-0.5)^2'
    args = 'xNd2 xAs2'
    constant_names = 'dENdAs factor1 L0UNd_p2 L0UAs_p2 L0NdAs_p2'
    constant_expressions = '-1.57 200 1.01 11.38 16.65'
    function = 'xU2:=1-xNd2-xAs2; 0.5*-0.21585 + 0.5*-0.263903 + dENdAs
                + factor1*((xNd2-0.5)^2 + (xAs2-0.5)^2)
                + 0
                + 0'
  [../]
  [./f3]
    type = DerivativeParsedMaterial
    f_name = F3
    #args = 'c3'
    #function = '20*(c3-0.8)^2'
    args = 'xNd3 xAs3'
    constant_names = 'factor2 L0UNd_p3 L0NdAs_p3 L0UAs_p3'
    constant_expressions = '100 -1.46 3.60 3.52'
    function = 'xU3:=1-xNd3-xAs3; 0.5*-0.08724 + 0.5*-0.26 + -1.03
                + factor2*((0.5-xNd3-xAs3)*(0.5-xNd3-xAs3) + (xAs3-0.5)*(xAs3-0.5))
                + 0
                + 0'
  [../]

  # Switching functions for each phase
  # h1(eta1, eta2, eta3)
  [./h1]
    type = SwitchingFunction3PhaseMaterial
    eta_i = eta1
    eta_j = eta2
    eta_k = eta3
    f_name = h1
  [../]
  # h2(eta1, eta2, eta3)
  [./h2]
    type = SwitchingFunction3PhaseMaterial
    eta_i = eta2
    eta_j = eta3
    eta_k = eta1
    f_name = h2
  [../]
  # h3(eta1, eta2, eta3)
  [./h3]
    type = SwitchingFunction3PhaseMaterial
    eta_i = eta3
    eta_j = eta1
    eta_k = eta2
    f_name = h3
  [../]

  # Coefficients for diffusion equation
  [./Dh1]
    type = DerivativeParsedMaterial
    material_property_names = 'D h1'
    function = D*h1
    f_name = Dh1
  [../]
  [./Dh2]
    type = DerivativeParsedMaterial
    material_property_names = 'D h2'
    function = D*h2
    f_name = Dh2
  [../]
  [./Dh3]
    type = DerivativeParsedMaterial
    material_property_names = 'D h3'
    function = D*h3
    f_name = Dh3
  [../]

  # Barrier functions for each phase
  [./g1]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta1
    function_name = g1
  [../]
  [./g2]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta2
    function_name = g2
  [../]
  [./g3]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta3
    function_name = g3
  [../]

  # constant properties
  [./constants]
    type = GenericConstantMaterial
    prop_names  = 'L   kappa  D'
    prop_values = '0.7 1.0    1'
  [../]
[]

[Kernels]
  #Kernels for diffusion equation
  [./diff_time_xNd]
    type = TimeDerivative
    variable = xNd
  [../]
  [./diff_time_xAs]
    type = TimeDerivative
    variable = xAs
  [../]
  [./diff_xNd1]
    type = MatDiffusion
    variable = xNd
    diffusivity = Dh1
    v = xNd1
  [../]
  [./diff_xNd2]
    type = MatDiffusion
    variable = xNd
    diffusivity = Dh2
    v = xNd2
  [../]
  [./diff_xNd3]
    type = MatDiffusion
    variable = xNd
    diffusivity = Dh3
    v = xNd3
  [../]
  [./diff_xAs1]
    type = MatDiffusion
    variable = xAs
    diffusivity = Dh1
    v = xAs1
  [../]
  [./diff_xAs2]
    type = MatDiffusion
    variable = xAs
    diffusivity = Dh2
    v = xAs2
  [../]
  [./diff_xAs3]
    type = MatDiffusion
    variable = xAs
    diffusivity = Dh3
    v = xAs3
  [../]

  # Kernels for Allen-Cahn equation for eta1
  [./deta1dt]
    type = TimeDerivative
    variable = eta1
  [../]
  [./ACBulkF1]
    type = KKSMultiACBulkF
    variable  = eta1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g1
    eta_i     = eta1
    wi        = 1.0
    args      = 'xNd1 xNd2 xNd3 xAs1 xAs2 xAs3 eta2 eta3'
  [../]
  [./ACBulkC1_xNd]
    type = KKSMultiACBulkC
    variable  = eta1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xNd1 xNd2 xNd3'
    eta_i     = eta1
    args      = 'xAs1 xAs2 xAs3 eta2 eta3'
  [../]
  [./ACBulkC1_xAs]
    type = KKSMultiACBulkC
    variable  = eta1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xAs1 xAs2 xAs3'
    eta_i     = eta1
    args      = 'xNd1 xNd2 xNd3 eta2 eta3'
  [../]
  [./ACInterface1]
    type = ACInterface
    variable = eta1
    kappa_name = kappa
  [../]
  [./multipler1]
    type = MatReaction
    variable = eta1
    v = lambda
    mob_name = L
  [../]

  # Kernels for Allen-Cahn equation for eta2
  [./deta2dt]
    type = TimeDerivative
    variable = eta2
  [../]
  [./ACBulkF2]
    type = KKSMultiACBulkF
    variable  = eta2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g2
    eta_i     = eta2
    wi        = 1.0
    args      = 'xNd1 xNd2 xNd3 xAs1 xAs2 xAs3 eta1 eta3'
  [../]
  [./ACBulkC2_xNd]
    type = KKSMultiACBulkC
    variable  = eta2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xNd1 xNd2 xNd3'
    eta_i     = eta2
    args      = 'xAs1 xAs2 xAs3 eta1 eta3'
  [../]
  [./ACBulkC2_xAs]
    type = KKSMultiACBulkC
    variable  = eta2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xAs1 xAs2 xAs3'
    eta_i     = eta2
    args      = 'xNd1 xNd2 xNd3 eta1 eta3'
  [../]
  [./ACInterface2]
    type = ACInterface
    variable = eta2
    kappa_name = kappa
  [../]
  [./multipler2]
    type = MatReaction
    variable = eta2
    v = lambda
    mob_name = L
  [../]

  # Kernels for the Lagrange multiplier equation
  [./mult_lambda]
    type = MatReaction
    variable = lambda
    mob_name = 3
  [../]
  [./mult_ACBulkF_1]
    type = KKSMultiACBulkF
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g1
    eta_i     = eta1
    wi        = 1.0
    mob_name  = 1
    args      = 'xNd1 xNd2 xNd3 xAs1 xAs2 xAs3 eta2 eta3'
  [../]
  [./mult_ACBulkC_1_xNd]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xNd1 xNd2 xNd3'
    eta_i     = eta1
    args      = 'xAs1 xAs2 xAs3 eta2 eta3'
    mob_name  = 1
  [../]
  [./mult_ACBulkC_1_xAs]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xAs1 xAs2 xAs3'
    eta_i     = eta1
    args      = 'xNd1 xNd2 xNd3 eta2 eta3'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_1]
    type = SimpleCoupledACInterface
    variable = lambda
    v = eta1
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_2]
    type = KKSMultiACBulkF
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g2
    eta_i     = eta2
    wi        = 1.0
    mob_name  = 1
    args      = 'xNd1 xNd2 xNd3 xAs1 xAs2 xAs3 eta1 eta3'
  [../]
  [./mult_ACBulkC_2_xNd]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xNd1 xNd2 xNd3'
    eta_i     = eta2
    args      = 'xAs1 xAs2 xAs3 eta1 eta3'
    mob_name  = 1
  [../]
  [./mult_ACBulkC_2_xAs]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xAs1 xAs2 xAs3'
    eta_i     = eta2
    args      = 'xNd1 xNd2 xNd3 eta1 eta3'
    mob_name  = 1
  [../]

  [./mult_CoupledACint_2]
    type = SimpleCoupledACInterface
    variable = lambda
    v = eta2
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_3]
    type = KKSMultiACBulkF
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g3
    eta_i     = eta3
    wi        = 1.0
    mob_name  = 1
    args      = 'xNd1 xNd2 xNd3 xAs1 xAs2 xAs3 eta1 eta2'
  [../]
  [./mult_ACBulkC_3_xNd]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xNd1 xNd2 xNd3'
    eta_i     = eta3
    args      = 'xAs1 xAs2 xAs3 eta1 eta2'
    mob_name  = 1
  [../]
  [./mult_ACBulkC_3_xAs]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xAs1 xAs2 xAs3'
    eta_i     = eta3
    args      = 'xNd1 xNd2 xNd3 eta1 eta2'
    mob_name  = 1
  [../]

  [./mult_CoupledACint_3]
    type = SimpleCoupledACInterface
    variable = lambda
    v = eta3
    kappa_name = kappa
    mob_name = 1
  [../]

  # Kernels for constraint equation eta1 + eta2 + eta3 = 1
  # eta3 is the nonlinear variable for the constraint equation
  [./eta3reaction]
    type = MatReaction
    variable = eta3
    mob_name = 1
  [../]
  [./eta1reaction]
    type = MatReaction
    variable = eta3
    v = eta1
    mob_name = 1
  [../]
  [./eta2reaction]
    type = MatReaction
    variable = eta3
    v = eta2
    mob_name = 1
  [../]
  [./one]
    type = BodyForce
    variable = eta3
    value = -1.0
  [../]

  # Phase concentration constraints
  [./chempot12_xNd]
    type = KKSPhaseChemicalPotential
    variable = xNd1
    cb       = xNd2
    fa_name  = F1
    fb_name  = F2
    args_a = xAs1
    args_b = xAs2
  [../]
  [./chempot12_xAs]
    type = KKSPhaseChemicalPotential
    variable = xAs1
    cb       = xAs2
    fa_name  = F1
    fb_name  = F2
    args_a = xNd1
    args_b = xNd2
  [../]
  [./chempot23_xNd]
    type = KKSPhaseChemicalPotential
    variable = xNd2
    cb       = xNd3
    fa_name  = F2
    fb_name  = F3
    args_a = xAs2
    args_b = xAs3
  [../]
  [./chempot23_xAs]
    type = KKSPhaseChemicalPotential
    variable = xAs2
    cb       = xAs3
    fa_name  = F2
    fb_name  = F3
    args_a = xNd2
    args_b = xNd3
  [../]
  [./phaseconcentration_xNd]
    type = KKSMultiPhaseConcentration
    variable = xNd3
    cj = 'xNd1 xNd2 xNd3'
    hj_names = 'h1 h2 h3'
    etas = 'eta1 eta2 eta3'
    c = xNd
  [../]
  [./phaseconcentration_xAs]
    type = KKSMultiPhaseConcentration
    variable = xAs3
    cj = 'xAs1 xAs2 xAs3'
    hj_names = 'h1 h2 h3'
    etas = 'eta1 eta2 eta3'
    c = xAs
  [../]
[]

[AuxKernels]
  [./Energy_total]
    type = KKSMultiFreeEnergy
    Fj_names = 'F1 F2 F3'
    hj_names = 'h1 h2 h3'
    gj_names = 'g1 g2 g3'
    variable = Energy
    w = 1
    interfacial_vars =  'eta1  eta2  eta3'
    kappa_names =       'kappa kappa kappa'
  [../]
[]

#[Executioner]
#  type = Transient
#  solve_type = 'PJFNK'
#  petsc_options_iname = '-pc_type -sub_pc_type   -sub_pc_factor_shift_type'
#  petsc_options_value = 'asm       ilu            nonzero'
#  l_max_its = 30
#  nl_max_its = 10
#  l_tol = 1.0e-4
#  nl_rel_tol = 1.0e-10
#  nl_abs_tol = 1.0e-11
#
#  num_steps = 100
#  dt = 0.5
#[]
#
#[Preconditioning]
#  active = 'full'
#  [./full]
#    type = SMP
#    full = true
#  [../]
#  [./mydebug]
#    type = FDP
#    full = true
#  [../]
#[]
#
#[Outputs]
#  exodus = true
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

[Postprocessors]
  [./XNd]
    type = ElementAverageValue
    variable = xNd
  [../]
  [./XAs]
    type = ElementAverageValue
    variable = xAs
  [../]
  [./Ftotal]
    type = ElementIntegralVariablePostprocessor
    variable = Energy
  [../]
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
  csv = true
[]
