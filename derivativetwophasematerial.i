[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 1
  nz = 0
  xmin = 0
  xmax = 10
  ymin = 0
  ymax = 1
  elem_type = QUAD4
[]

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = FunctionIC
      function = x/10
    [../]
  [../]
  [./w]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = FunctionIC
      function = (10-x)/10
    [../]
  [../]
[]

[Kernels]
  [./detadt]
    type = TimeDerivative
    variable = eta
  [../]
  [./ACBulk]
    type = AllenCahn
    variable = eta
    args = c
    f_name = F
  [../]
  [./ACInterface]
    type = ACInterface
    variable = eta
    kappa_name = kappa_eta
  [../]

  [./c_res]
    type = SplitCHParsed
    variable = c
    f_name = F
    kappa_name = kappa_c
    w = w
    args = 'eta'
  [../]
  [./w_res]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
  [./time]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
[]

[BCs]
  [./Periodic]
    [./All]
      auto_direction = 'x'
    [../]
  [../]
[]

[Materials]
  [./consts]
    type = GenericConstantMaterial
    prop_names  = 'L kappa_eta'
    prop_values = '3.6595e-01 2.187e-02'
  [../]
  [./consts2]
    type = GenericConstantMaterial
    prop_names  = 'M kappa_c'
    prop_values = '3.6595e-02 2.187e-02'
  [../]

  [./switching]
    type = SwitchingFunctionMaterial
    eta = eta
    h_order = SIMPLE
  [../]
  [./barrier]
    type = BarrierFunctionMaterial
    eta = eta
    g_order = SIMPLE
  [../]

  [./free_energy_A]
    type = DerivativeParsedMaterial
    f_name = Fa
    args = 'c'
    function = '0.00028*c^2-0.0000165*c-0.00017795'
    derivative_order = 2
    enable_jit = true
  [../]
  [./free_energy_B]
    type = DerivativeParsedMaterial
    f_name = Fb
    args = 'c'
    function = '0.000194*c^2-0.00036+0.000013231'
    derivative_order = 2
    enable_jit = true
  [../]

  [./free_energy]
    type = DerivativeTwoPhaseMaterial
    f_name = F
    fa_name = Fa
    fb_name = Fb
    args = c
    eta = eta
    derivative_order = 2
    outputs = exodus
  [../]
[]

[AuxKernels]
 [./local_energy]
 type = TotalFreeEnergy
 variable = F
 f_name = F
 interfacial_vars = c
 kappa_names = kappa_c
 execute_on = 'initial linear'
 [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = 'bdf2'
  solve_type = 'NEWTON'

  l_max_its = 15
  l_tol = 1.0e-4

  nl_max_its = 10
  nl_rel_tol = 1.0e-11

  start_time = 0.0
  num_steps = 10000
  dt = 0.5
[]

[Outputs]
  exodus = true
  csv = true
  gnuplot = true
[]
