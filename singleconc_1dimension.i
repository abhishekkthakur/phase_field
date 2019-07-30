#
# This test is for the 3-phase KKS model
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 200
  ny = 1
  nz = 0
  xmin = -10
  xmax = 10
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
  [../]
[]

[AuxVariables]
  [./Energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Variables]
  # concentration
  [./c]
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
  [../]

  # order parameter 3
  [./eta3]
    order = FIRST
    family = LAGRANGE
    #initial_condition = 0.0
  [../]

  # phase concentration 1
  [./xu]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.1
  [../]

  # phase concentration 2
  [./xnd]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.28
  [../]

  # phase concentration 3
  [./xas]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.43
  [../]

  # Lagrange multiplier
  [./lambda]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]
[]

[Functions]
  [./f_eta1]
    type = ParsedFunction
    #value = x/180
    value = (tanh(x)+1)/2
  [../]
  [./f_eta2]
    type = ParsedFunction
    #value = (60+x)/180
    value = (tanh(x*5)+1)/2
  [../]
  [./f_eta3]
    type = ParsedFunction
    #value = (120+x)/180
    value = (tanh(x*3)+1)/2
  [../]
  [./f_c]
    type = ParsedFunction
    #value = x/180
    value = (tanh(x))/2
  [../]
[]

[ICs]
  [./eta1]
    variable = eta1
    #type = FunctionIC
    #function = f_eta1
    type = RandomIC
    min = 0.4
    max = 0.6
    #type = SmoothCircleIC
    #x1 = 20.0
    #y1 = 20.0
    #radius = 10
    #invalue = 0.9
    #outvalue = 0.1
    #int_width = 4
  [../]
  [./eta2]
    variable = eta2
    #type = FunctionIC
    #function = f_eta2
    type = RandomIC
    min = 0.4
    max = 0.6
    #type = SmoothCircleIC
    #x1 = 20.0
    #y1 = 20.0
    #radius = 10
    #invalue = 0.1
    #outvalue = 0.9
    #int_width = 4
  [../]
  [./eta3]
    variable = eta3
    #type = FunctionIC
    #function = f_eta3
    type = RandomIC
    min = 0.4
    max = 0.6
  [../]
  [./c]
    variable = c
    #type = FunctionIC
    #function = f_c
    type = RandomIC
    min = 0.4
    max = 0.6
    #type = SmoothCircleIC
    #x1 = 20.0
    #y1 = 20.0
    #radius = 10
    #invalue = 0.2
    #outvalue = 0.5
    #int_width = 2
  [../]
[]


[Materials]
  [./f1]
    type = DerivativeParsedMaterial
    f_name = F1
    args = 'xu xnd xas'
    function = 'xu*-0.15608 + xnd*0.05182 + xas*0.05182 + 3*xas*xas*-1.44 + 3*xnd*xnd*2.60 + 3*xnd*xas*-3.225
                + 8.314*300*(xu*log(xu) + xnd*log(xnd) + xas*log(xas))
                + xu*xnd*4.17 + xu*xas*-1.04 + xnd*xas*-3.225'
  [../]
  [./f2]
    type = DerivativeParsedMaterial
    f_name = F2
    args = 'xu xnd xas'
    function = '-12.572 + 7*((xnd-0.5)*(xnd-0.5) + (xas-0.5)*(xas-0.5))
                + 0.5*8.314*300*(2*xu*log(2*xu) + (1-2*xu)*log(1-2*xu))
                + xu*xnd*1.01 + xu*xas*11.38 + xnd*xas*16.65'
  [../]
  [./f3]
    type = DerivativeParsedMaterial
    f_name = F3
    args = 'xu xnd xas'
    # If you remove the excess part from the equation below then the solution will converge.
    function = 'xu*-0.08724 + xnd*-0.23777 + xas*-0.23205
                + 8.314*300*(xu*log(xu) + xnd*log(xnd) + xas*log(xas))
                + xu*xnd*-1.46 + xnd*xas*3.6 + xu*xas*3.52'
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
  [./diff_time]
    type = TimeDerivative
    variable = c
  [../]
  [./diff_c1]
    type = MatDiffusion
    variable = c
    D_name = Dh1
    conc = xu
  [../]
  [./diff_c2]
    type = MatDiffusion
    variable = c
    D_name = Dh2
    conc = xnd
  [../]
  [./diff_c3]
    type = MatDiffusion
    variable = c
    D_name = Dh3
    conc = xas
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
    args      = 'xu xnd xas eta2 eta3'
  [../]
  [./ACBulkC1]
    type = KKSMultiACBulkC
    variable  = eta1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu xnd xas'
    eta_i     = eta1
    args      = 'eta2 eta3'
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
    args      = 'xu xnd xas eta1 eta3'
  [../]
  [./ACBulkC2]
    type = KKSMultiACBulkC
    variable  = eta2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu xnd xas'
    eta_i     = eta2
    args      = 'eta1 eta3'
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
    args      = 'xu xnd xas eta2 eta3'
  [../]
  [./mult_ACBulkC_1]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu xnd xas'
    eta_i     = eta1
    args      = 'eta2 eta3'
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
    args      = 'xu xnd xas eta1 eta3'
  [../]
  [./mult_ACBulkC_2]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu xnd xas'
    eta_i     = eta2
    args      = 'eta1 eta3'
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
    args      = 'xu xnd xas eta1 eta2'
  [../]
  [./mult_ACBulkC_3]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu xnd xas'
    eta_i     = eta3
    args      = 'eta1 eta2'
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
  [./chempot12]
    type = KKSPhaseChemicalPotential
    variable = xu
    args_a = xnd
    args_b = xas
    cb       = xnd
    fa_name  = F1
    fb_name  = F2
  [../]
  [./chempot23]
    type = KKSPhaseChemicalPotential
    variable = xnd
    args_a = xu
    args_b = xas
    cb       = xas
    fa_name  = F2
    fb_name  = F3
  [../]
  [./phaseconcentration]
    type = KKSMultiPhaseConcentration
    variable = xas
    cj = 'xu xnd xas'
    hj_names = 'h1 h2 h3'
    etas = 'eta1 eta2 eta3'
    c = c
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

[Executioner]
  type = Transient
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -sub_pc_type   -sub_pc_factor_shift_type'
  petsc_options_value = 'asm       ilu            nonzero'
  l_max_its = 30
  nl_max_its = 10
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-10
  nl_abs_tol = 1.0e-11

  end_time = 1e10
  #num_steps = 2
  #dt = 10

  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    iteration_window = 2
    dt = 1e-3
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

[Outputs]
  exodus = true
[]
