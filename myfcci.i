# This file is for KKS model implemented for 3 phase, 2 global concentration and 9 local
# concentrations. We have used 6 local concentrations as 3 are defined implicitly.

# Mesh and node generation part.
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

# Energy declaration part.
[AuxVariables]
  [./Energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

# Variable declaration part.
[Variables]
  # Global concentrations.
  [./xAs]
    order = FIRST
    family = LAGRANGE
  [../]
  [./xNd]
    order = FIRST
    family = LAGRANGE
  [../]

  # order parameters. eta1, eta2 and eta3 for phase 1, phase 2 and phase 3 respectively.
  [./eta1]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta2]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta3]
    order = FIRST
    family = LAGRANGE
  [../]

  # Local concentration of As in Phase 1.
  [./xAs1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.7
  [../]
  # Local concentration of Nd in Phase 1.
  [./xNd1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.1
  [../]
  # Local concentration of As in Phase 2.
  [./xAs2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.8
  [../]
  # Local concentration of Nd in Phase 2.
  [./xNd2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.11
  [../]
  # Local concentration of As in Phase 3.
  [./xAs3]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.55
  [../]
  # Local concentration of Nd in Phase 3.
  [./xNd3]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.11
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
    value = (-tanh(x+5)+1)/2
  [../]
  [./f_eta2]
    type = ParsedFunction
    value = (tanh(x+5)+1-tanh(x-5)-1)/2
  [../]
  [./f_eta3]
    type = ParsedFunction
    value = (tanh(x-3)+1)/2
  [../]
  [./f_c]
    type = ParsedFunction
    value = (tanh(x))/2
  [../]
[]

# Initial condition block. This is very important.
[ICs]
  [./eta1]
    variable = eta1
    type = FunctionIC
    function = f_eta1
  [../]
  [./eta2]
    variable = eta2
    type = FunctionIC
    function = f_eta2
  [../]
  [./eta3]
    variable = eta3
    type = FunctionIC
    function = f_eta3
  [../]
  [./xAs]
    variable = xAs
    type = RandomIC
    min = 0.4
    max = 0.45
  [../]
  [./xNd]
    variable = xNd
    type = RandomIC
    min = 0.4
    max = 0.45
  [../]
[]

# Materials block. Here we define free energy expression for each phase as a function of local
# compositions of that phase.
[Materials]
  [./f1]
    type = DerivativeParsedMaterial
    f_name = F1
    args = 'xAs1 xNd1'
    constant_names = 'dEAsAs_p1 dENdNd_p1 dENdAs_p1 L0UNd_p1 L0NdAs_p1 L0UAs_p1'
    constant_expressions = '-1.44 2.60 -3.225 4.17 -3.225 -1.04'
    function = 'xU1:=1-xAs1-xNd1; xU1*-0.15608 + xNd1*0.05182 + xAs1*0.05182 + 3*xAs1*xAs1*dEAsAs_p1 + 3*xNd1*xNd1*dENdNd_p1 + 3*xNd1*xAs1*dENdAs_p1
                + 8.314*300*(xU1*log(xU1) + xNd1*log(xNd1) + xAs1*log(xAs1))
                + xU1*xNd1*L0UNd_p1 + xU1*xAs1*L0UAs_p1 + xNd1*xAs1*L0NdAs_p1'
  [../]
  [./f2]
    type = DerivativeParsedMaterial
    f_name = F2
    args = 'xAs2 xNd2'
    constant_names = 'factor L0UNd_p2 L0UAs_p2 L0NdAs_p2'
    constant_expressions = '200 1.01 11.38 16.65'
    function = 'xU2:=1-xAs2-xNd2; -12.572 + factor*((xNd2-0.5)*(xNd2-0.5) + (xAs2-0.5)*(xAs2-0.5))
                + xU2*xNd2*L0UNd_p2 + xU2*xAs2*L0UAs_p2 + xNd2*xAs2*L0NdAs_p2'
                #+ 8.314*300*(xU2*log(xU2) + xNd2*log(xNd2) + xAs2*log(xAs2))

  [../]
  [./f3]
    type = DerivativeParsedMaterial
    f_name = F3
    args = 'xAs3 xNd3'
    constant_names = 'L0UNd_p3 L0NdAs_p3 L0UAs_p3'
    constant_expressions = '-1.46 3.60 3.52'
    function = 'xU3:=1-xAs3-xNd3; xU3*-0.08724 + xNd3*-0.23777 + xAs3*-0.23205
                + 8.314*300*(xU3*log(xU3) + xNd3*log(xNd3) + xAs3*log(xAs3))
                + xU3*xNd3*L0UNd_p3 + xNd3*xAs3*L0NdAs_p3 + xU3*xAs3*L0UAs_p3'
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
    material_property_names = 'D h1(eta1,eta2,eta3)'
    function = D*h1
    f_name = Dh1
    args = 'eta1 eta2 eta3'
  [../]
  [./Dh2]
    type = DerivativeParsedMaterial
    material_property_names = 'D h2(eta1,eta2,eta3)'
    function = D*h2
    f_name = Dh2
    args = 'eta1 eta2 eta3'
  [../]
  [./Dh3]
    type = DerivativeParsedMaterial
    material_property_names = 'D h3(eta1,eta2,eta3)'
    function = D*h3
    f_name = Dh3
    args = 'eta1 eta2 eta3'
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

  # This is for xNd global concentration.
  [./diff_time_1]      # This is the time derivative for xNd (first global concentration).
    type = TimeDerivative
    variable = xNd
  [../]
  [./diff_c1_1]       # This is the divergence of summation of the product of h and c. Check MatDiffusion to clarify.
    type = MatDiffusion
    variable = xNd
    #diffusivity = Dh1
    D_name = Dh1
    args = 'eta1 eta2 eta3'
    #v = xNd1
  [../]
  [./diff_c1_2]
    type = MatDiffusion
    variable = xNd
    #diffusivity = Dh2
    D_name = Dh2
    #v = xNd2
    args = 'eta1 eta2 eta3'
  [../]
  [./diff_c1_3]
    type = MatDiffusion
    variable = xNd
    #diffusivity = Dh3
    D_name = Dh3
    #v = xNd3
    args = 'eta1 eta2 eta3'
  [../]


  # This is for xAs global concentration.
  [./diff_time_2]
    type = TimeDerivative
    variable = xAs
  [../]
  [./diff_c2_1]
    type = MatDiffusion
    variable = xAs
    #diffusivity = Dh1
    D_name = Dh1
    #v = xAs1
    args = 'eta1 eta2 eta3'
  [../]
  [./diff_c2_2]
    type = MatDiffusion
    variable = xAs
    #diffusivity = Dh2
    D_name = Dh2
    #v = xAs2
    args = 'eta1 eta2 eta3'
  [../]
  [./diff_c2_3]
    type = MatDiffusion
    variable = xAs
    #diffusivity = Dh3
    D_name = Dh3
    #v = xAs3
    args = 'eta1 eta2 eta3'
  [../]

  # Kernels for Allen-Cahn equation for eta1 for global concentrations xNd and xAs.
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
    args      = 'xNd1 xNd2 xNd3 xAs1 xAs2 xAs3 eta2 eta3'
  [../]
  [./ACBulkC1_1]
    type = KKSMultiACBulkC
    variable  = eta1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xNd1 xNd2 xNd3'
    eta_i     = eta1
    #args      = 'eta2 eta3'
    args      = 'xAs1 xAs2 xAs3 eta2 eta3'
  [../]
  [./ACBulkC1_2]
    type = KKSMultiACBulkC
    variable  = eta1
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xAs1 xAs2 xAs3'
    eta_i     = eta1
    #args      = 'eta2 eta3'
    args      = 'xNd1 xNd2 xNd3 eta2 eta3'
  [../]
  [./ACInterface1_1]
    type = ACInterface
    variable = eta1
    kappa_name = kappa
  [../]
  [./multipler1_1]
    type = MatReaction
    variable = eta1
    v = lambda
    mob_name = L
  [../]


  # Kernels for Allen-Cahn equation for eta2 for global concentrations xNd and xAs.
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
    args      = 'xNd1 xNd2 xNd3 xAs1 xAs2 xAs3 eta1 eta3'
  [../]
  [./ACBulkC2_1]
    type = KKSMultiACBulkC
    variable  = eta2
    Fj_names  = 'F1   F2   F3'
    hj_names  = 'h1   h2   h3'
    cj_names  = 'xNd1 xNd2 xNd3'
    eta_i     = eta2
    #args      = 'eta1 eta3'
    args      = 'xAs1 xAs2 xAs3 eta1 eta3'
  [../]
  [./ACBulkC2_2]
    type = KKSMultiACBulkC
    variable  = eta2
    Fj_names  = 'F1   F2   F3'
    hj_names  = 'h1   h2   h3'
    cj_names  = 'xAs1 xAs2 xAs3'
    eta_i     = eta2
    #args      = 'eta1 eta3'
    args      = 'xNd1 xNd2 xNd3 eta1 eta3'
  [../]
  [./ACInterface2_1]
    type = ACInterface
    variable = eta2
    kappa_name = kappa
  [../]
  [./multipler2_1]
    type = MatReaction
    variable = eta2
    v = lambda
    mob_name = L
  [../]


  # Kernels for the Lagrange multiplier equation for both .
  [./mult_lambda_1]
    type = MatReaction
    variable = lambda
    mob_name = 3
  [../]
  [./mult_ACBulkF_1_1]
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
  [./mult_ACBulkC_1_1]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xNd1 xNd2 xNd3'
    eta_i     = eta1
    #args = 'eta2 eta3'
    args      = 'xAs1 xAs2 xAs3 eta2 eta3'
    mob_name  = 1
  [../]
  [./mult_ACBulkC_1_2]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xAs1 xAs2 xAs3'
    eta_i     = eta1
    #args = 'eta2 eta3'
    args      = 'xNd1 xNd2 xNd3 eta2 eta3'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_1_1]
    type = SimpleCoupledACInterface
    variable = lambda
    v = eta1
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_2_1]
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
  [./mult_ACBulkC_2_1]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xNd1 xNd2 xNd3'
    eta_i     = eta2
    #args = 'eta1 eta3'
    args      = 'xAs1 xAs2 xAs3 eta1 eta3'
    mob_name  = 1
  [../]
  [./mult_ACBulkC_2_2]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xAs1 xAs2 xAs3'
    eta_i     = eta2
    #args = 'eta1 eta3'
    args      = 'xNd1 xNd2 xNd3 eta1 eta3'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_2_1]
    type = SimpleCoupledACInterface
    variable = lambda
    v = eta2
    kappa_name = kappa
    mob_name = 1
  [../]
  [./mult_ACBulkF_3_1]
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
  [./mult_ACBulkC_3_1]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xNd1 xNd2 xNd3'
    eta_i     = eta3
    #args = 'eta1 eta2'
    args      = 'xAs1 xAs2 xAs3 eta1 eta2'
    mob_name  = 1
  [../]
  [./mult_ACBulkC_3_2]
    type = KKSMultiACBulkC
    variable  = lambda
    Fj_names  = 'F1 F2 F3'
    hj_names  = 'h1 h2 h3'
    cj_names  = 'xAs1 xAs2 xAs3'
    eta_i     = eta3
    #args = 'eta1 eta2'
    args      = 'xNd1 xNd2 xNd3 eta1 eta2'
    mob_name  = 1
  [../]
  [./mult_CoupledACint_3_1]
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


  # Phase concentration constraints for global concentration 1.
  [./chempot12_1]
    type = KKSPhaseChemicalPotential
    variable = xAs1
    cb       = xAs2
    args_a = 'xNd2'
    args_b = 'xNd1'
    fa_name  = F1
    fb_name  = F2
  [../]

  [./chempot23_1]
    type = KKSPhaseChemicalPotential
    variable = xAs2
    cb       = xAs3
    args_a = 'xNd3'
    args_b = 'xNd2'
    fa_name  = F2
    fb_name  = F3
  [../]

  [./phaseconcentration_1]
    type = KKSMultiPhaseConcentration
    variable = xAs3
    cj       = 'xAs1 xAs2 xAs3'
    hj_names = 'h1   h2   h3'
    etas = 'eta1 eta2 eta3'
    c = xAs
  [../]


  # Phase concentration constraints for global concentration 2.
  [./chempot12_2]
    type = KKSPhaseChemicalPotential
    variable = xNd1
    cb       = xNd2
    args_a = 'xAs2'
    args_b = 'xAs1'
    fa_name  = F1
    fb_name  = F2
  [../]

  [./chempot23_2]
    type = KKSPhaseChemicalPotential
    variable = xNd2
    cb       = xNd3
    args_a = 'xAs3'
    args_b = 'xAs2'
    fa_name  = F2
    fb_name  = F3
  [../]

  [./phaseconcentration_2]
    type = KKSMultiPhaseConcentration
    variable = xNd3
    cj       = 'xNd1 xNd2 xNd3'
    hj_names = 'h1   h2   h3'
    etas = 'eta1 eta2 eta3'
    c = xNd
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
  nl_max_its = 15
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-9
  nl_abs_tol = 1.0e-9

  end_time = 1e3

  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    iteration_window = 2
    growth_factor = 1.5
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
  print_linear_residuals = false
[]
