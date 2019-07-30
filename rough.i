#
# This test is for the 3-phase KKS model
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
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

#[BCs]
#  [./Periodic]
#    [./all]
#      auto_direction = 'x y'
#    [../]
#  [../]
#[]

[AuxVariables]
  [./Energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Variables]
  # concentration
  [./c1]
    order = FIRST
    family = LAGRANGE
  [../]
  [./c2]
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
  [./xu1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.3
  [../]
  [./xu2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.3
  [../]
  # phase concentration 2
  [./xnd1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.35
  [../]
  [./xnd2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.35
  [../]
  # phase concentration 3
  [./xas1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.35
  [../]
  [./xas2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.35
  [../]
  # Lagrange multiplier
  [./lambda1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]
  [./lambda2]
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
    min = 0.1
    max = 0.2
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
    min = 0.1
    max = 0.3
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
    min = 0.1
    max = 0.3
  [../]
  [./c1]
    variable = c1
    #type = FunctionIC
    #function = f_c
    type = RandomIC
    min = 0.9
    max = 1
    #type = SmoothCircleIC
    #x1 = 20.0
    #y1 = 20.0
    #radius = 10
    #invalue = 0.2
    #outvalue = 0.5
    #int_width = 2
  [../]
  [./c2]
    variable = c2
    type = RandomIC
    min = 0.9
    max = 1
  [../]
[]


[Materials]
  [./f1]
    type = DerivativeParsedMaterial
    f_name = F1
    args = 'xu1 xnd1 xas1'
    function = 'xu1*-0.15608 + xnd1*0.05182 + xas1*0.05182 + 3*xas1*xas1*-1.44 + 3*xnd1*xnd1*2.60 + 3*xnd1*xas1*-3.225
                + 8.314*300*(xu1*log(xu1) + xnd1*log(xnd1) + xas1*log(xas1))
                + xu1*xnd1*4.17 + xu1*xas1*-1.04 + xnd1*xas1*-3.225'
  [../]
  [./f2]
    type = DerivativeParsedMaterial
    f_name = F2
    args = 'xu2 xnd2 xas2'
    function = '-12.572 + 7*((xnd2-0.5)*(xnd2-0.5) + (xas2-0.5)*(xas2-0.5))
                + 0.5*8.314*300*(2*xu2*log(2*xu2) + (1-2*xu2)*log(1-2*xu2))
                + xu2*xnd2*1.01 + xu2*xas2*11.38 + xnd2*xas2*16.65'
  [../]
  [./f3]
    type = DerivativeParsedMaterial
    f_name = F3
    args = 'xu1 xnd1 xas1 xu2 xnd2 xas2'
    # If you remove the excess part from the equation below then the solution will converge.
    function = '(1-xu1-xu2)*-0.08724 + (1-xnd1-xnd2)*-0.23777 + (1-xas1-xas2)*-0.23205
                + 8.314*300*((1-xu1-xu2)*log((1-xu1-xu2)) + (1-xnd1-xnd2)*log((1-xnd1-xnd2)) + (1-xas1-xas2)*log((1-xas1-xas2)))
                + (1-xu1-xu2)*(1-xnd1-xnd2)*-1.46 + (1-xnd1-xnd2)*(1-xas1-xas2)*3.6 + (1-xu1-xu2)*(1-xas1-xas2)*3.52'
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
  # This is for 1st global concentration.
  [./diff_time_1]
    type = TimeDerivative
    variable = c1
  [../]
  [./diff_c1_1]
    type = MatDiffusion
    variable = c1
    D_name = Dh1
    conc = xu1
  [../]
  [./diff_c2_1]
    type = MatDiffusion
    variable = c1
    D_name = Dh2
    conc = xnd1
  [../]
  [./diff_c3_1]
    type = MatDiffusion
    variable = c1
    D_name = Dh3
    conc = xas1
  [../]

  # This is for 2nd global concentration.
  [./diff_time_2]
    type = TimeDerivative
    variable = c2
  [../]
  [./diff_c1_2]
    type = MatDiffusion
    variable = c2
    D_name = Dh1
    conc = xu2
  [../]
  [./diff_c2_2]
    type = MatDiffusion
    variable = c2
    D_name = Dh2
    conc = xnd2
  [../]
  [./diff_c3_2]
    type = MatDiffusion
    variable = c2
    D_name = Dh3
    conc = xas2
  [../]











  # Kernels for Allen-Cahn equation for eta1 for global concentration 1.
  [./deta1dt_1]
    type = TimeDerivative
    variable = eta1
  [../]
  [./ACBulkF1_1]
    type = KKSMultiACBulkF
    variable  = eta1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g1
    eta_i     = eta1
    wi        = 1.0
    args      = 'xu1 xnd1 xas1 xu2 xnd2 xas2 eta2 eta3'
  [../]
  [./ACBulkC1_1]
    type = KKSMultiACBulkC
    variable  = eta1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu1 xnd1 xas1'
    eta_i     = eta1
    args      = 'xu2 xnd2 xas2 eta2 eta3'
  [../]
  [./ACInterface1_1]
    type = ACInterface
    variable = eta1
    kappa_name = kappa
  [../]
  [./multipler1_1]
    type = MatReaction
    variable = eta1
    v = lambda1
    mob_name = L
  [../]




  # Kernels for Allen-Cahn equation for eta1 for global concentration 2.
  [./deta1dt_2]
    type = TimeDerivative
    variable = eta1
  [../]
  [./ACBulkF1_2]
    type = KKSMultiACBulkF
    variable  = eta1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g1
    eta_i     = eta1
    wi        = 1.0
    args      = 'xu1 xnd1 xas1 xu2 xnd2 xas2 eta2 eta3'
  [../]
  [./ACBulkC1_2]
    type = KKSMultiACBulkC
    variable  = eta1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu2 xnd2 xas2'
    eta_i     = eta1
    args      = 'xu1 xnd1 xas1 eta2 eta3'
  [../]
  [./ACInterface1_2]
    type = ACInterface
    variable = eta1
    kappa_name = kappa
  [../]
  [./multipler1_2]
    type = MatReaction
    variable = eta1
    v = lambda2
    mob_name = L
  [../]












  # Kernels for Allen-Cahn equation for eta2 for 1st global concentration.
  [./deta2dt_1]
    type = TimeDerivative
    variable = eta2
  [../]
  [./ACBulkF2_1]
    type = KKSMultiACBulkF
    variable  = eta2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g2
    eta_i     = eta2
    wi        = 1.0
    args      = 'xu1 xnd1 xas1 xu2 xnd2 xas2 eta1 eta3'
  [../]
  [./ACBulkC2_1]
    type = KKSMultiACBulkC
    variable  = eta2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu1 xnd1 xas1'
    eta_i     = eta2
    args      = 'xu2 xnd2 xas2 eta1 eta3'
  [../]
  [./ACInterface2_1]
    type = ACInterface
    variable = eta2
    kappa_name = kappa
  [../]
  [./multipler2_1]
    type = MatReaction
    variable = eta2
    v = lambda1
    mob_name = L
  [../]







  # Kernels for Allen-Cahn equation for eta2 for 2nd global concentration.
  [./deta2dt_2]
    type = TimeDerivative
    variable = eta2
  [../]
  [./ACBulkF2_2]
    type = KKSMultiACBulkF
    variable  = eta2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g2
    eta_i     = eta2
    wi        = 1.0
    args      = 'xu1 xnd1 xas1 xu2 xnd2 xas2 eta1 eta3'
  [../]
  [./ACBulkC2_2]
    type = KKSMultiACBulkC
    variable  = eta2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu2 xnd2 xas2'
    eta_i     = eta2
    args      = 'xu1 xnd1 xas1 eta1 eta3'
  [../]
  [./ACInterface2_2]
    type = ACInterface
    variable = eta2
    kappa_name = kappa
  [../]
  [./multipler2_2]
    type = MatReaction
    variable = eta2
    v = lambda2
    mob_name = L
  [../]
















  # Kernels for the Lagrange multiplier equation for global concentration 1.
  [./mult_lambda_1]
    type = MatReaction
    variable = lambda1
    mob_name = 3
  [../]
  [./mult_ACBulkF_1_1]
    type = KKSMultiACBulkF
    variable  = lambda1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g1
    eta_i     = eta1
    wi        = 1.0
    mob_name  = 1
    args      = 'xu1 xnd1 xas1 xu2 xnd2 xas2 eta2 eta3'
  [../]
  [./mult_ACBulkC_1_1]
    type = KKSMultiACBulkC
    variable  = lambda1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu1 xnd1 xas1'
    eta_i     = eta1
    args      = 'xu2 xnd2 xas2 eta2 eta3'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_1_1]
    type = SimpleCoupledACInterface
    variable = lambda1
    v = eta1
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_2_1]
    type = KKSMultiACBulkF
    variable  = lambda1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g2
    eta_i     = eta2
    wi        = 1.0
    mob_name  = 1
    args      = 'xu1 xnd1 xas1 xu2 xnd2 xas2 eta1 eta3'
  [../]
  [./mult_ACBulkC_2_1]
    type = KKSMultiACBulkC
    variable  = lambda1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu1 xnd1 xas1'
    eta_i     = eta2
    args      = 'xu2 xnd2 xas2 eta1 eta3'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_2_1]
    type = SimpleCoupledACInterface
    variable = lambda1
    v = eta2
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_3_1]
    type = KKSMultiACBulkF
    variable  = lambda1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g3
    eta_i     = eta3
    wi        = 1.0
    mob_name  = 1
    args      = 'xu1 xnd1 xas1 xu2 xnd2 xas2 eta1 eta2'
  [../]
  [./mult_ACBulkC_3_1]
    type = KKSMultiACBulkC
    variable  = lambda1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu1 xnd1 xas1'
    eta_i     = eta3
    args      = 'xu2 xnd2 xas2 eta1 eta2'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_3_1]
    type = SimpleCoupledACInterface
    variable = lambda1
    v = eta3
    kappa_name = kappa
    mob_name = 1
  [../]









  # Kernels for the Lagrange multiplier equation for global concentration 2.
  [./mult_lambda_2]
    type = MatReaction
    variable = lambda2
    mob_name = 3
  [../]
  [./mult_ACBulkF_1_2]
    type = KKSMultiACBulkF
    variable  = lambda2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g1
    eta_i     = eta1
    wi        = 1.0
    mob_name  = 1
    args      = 'xu2 xnd2 xas2 xu1 xnd1 xas1 eta2 eta3'
  [../]
  [./mult_ACBulkC_1_2]
    type = KKSMultiACBulkC
    variable  = lambda2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu2 xnd2 xas2'
    eta_i     = eta1
    args      = 'xu1 xnd1 xas1 eta2 eta3'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_1_2]
    type = SimpleCoupledACInterface
    variable = lambda2
    v = eta1
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_2_2]
    type = KKSMultiACBulkF
    variable  = lambda2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g2
    eta_i     = eta2
    wi        = 1.0
    mob_name  = 1
    args      = 'xu1 xnd1 xas1 xu2 xnd2 xas2 eta1 eta3'
  [../]
  [./mult_ACBulkC_2_2]
    type = KKSMultiACBulkC
    variable  = lambda2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu2 xnd2 xas2'
    eta_i     = eta2
    args      = 'xu1 xnd1 xas1 eta1 eta3'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_2_2]
    type = SimpleCoupledACInterface
    variable = lambda2
    v = eta2
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_3_2]
    type = KKSMultiACBulkF
    variable  = lambda2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    gi_name   = g3
    eta_i     = eta3
    wi        = 1.0
    mob_name  = 1
    args      = 'xu1 xnd1 xas1 xu2 xnd2 xas2 eta1 eta2'
  [../]
  [./mult_ACBulkC_3_2]
    type = KKSMultiACBulkC
    variable  = lambda2
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xu2 xnd2 xas2'
    eta_i     = eta3
    args      = 'xu1 xnd1 xas1 eta1 eta2'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_3_2]
    type = SimpleCoupledACInterface
    variable = lambda2
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







  # Phase concentration constraints for global concentration 1.
  [./chempot12_1]
    type = KKSPhaseChemicalPotential
    variable = xu1
    args_a = 'xu2 xnd1 xnd2'
    args_b = 'xas1 xas2'
    cb       = xnd1
    fa_name  = F1
    fb_name  = F2
  [../]
  [./chempot23_1]
    type = KKSPhaseChemicalPotential
    variable = xnd1
    args_a = 'xu1 xu2 xnd2'
    args_b = 'xas1 xas2'
    cb       = xas1
    fa_name  = F2
    fb_name  = F3
  [../]
  [./phaseconcentration_1]
    type = KKSMultiPhaseConcentration
    variable = xas1
    cj = 'xu1 xnd1 xas1'
    hj_names = 'h1 h2 h3'
    etas = 'eta1 eta2 eta3'
    c = c1
  [../]





  # Phase concentration constraints for global concentration 2.
  [./chempot12_2]
    type = KKSPhaseChemicalPotential
    variable = xu2
    args_a = 'xnd2 xnd1 xu1'
    args_b = 'xas2 xas1'
    cb       = xnd2
    fa_name  = F1
    fb_name  = F2
  [../]
  [./chempot23_2]
    type = KKSPhaseChemicalPotential
    variable = xnd2
    args_a = 'xu2 xu1 xnd1'
    args_b = 'xas2 xas1'
    cb       = xas2
    fa_name  = F2
    fb_name  = F3
  [../]
  [./phaseconcentration_2]
    type = KKSMultiPhaseConcentration
    variable = xas2
    cj = 'xu2 xnd2 xas2'
    hj_names = 'h1 h2 h3'
    etas = 'eta1 eta2 eta3'
    c = c2
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
  l_max_its = 100
  nl_max_its = 100
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-5
  nl_abs_tol = 1.0e-5

  end_time = 1e7
  #num_steps = 2
  #dt = 10

  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    iteration_window = 2
    dt = 1e-5
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
