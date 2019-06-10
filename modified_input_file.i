[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 100
  ny = 1
  xmin = 0
  xmax = 10
  ymin = 0
  ymax = 1
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
  [./eta]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = FunctionIC
      function = (10-x)/10
    [../]
  [../]
  [./w]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[BCs]
  [./Periodic]
    [./c_bcs]
      auto_direction = 'x'
    [../]
  [../]
[]

[Kernels]
  [./w_dot]
    variable = w
    v = c
    type = CoupledTimeDerivative
  [../]
  [./coupled_res]
    variable = w
    type = SplitCHWRes
    mob_name = M
  [../]
  [./coupled_parsed]
    variable = c
    args = eta
    type = SplitCHParsed
    f_name = f_loc
    kappa_name = kappa_c
    w = w
  [../]
  [./ACInterface]
    type = ACInterface
    variable = eta
    kappa_name = kappa_eta
  [../]
[]

[Materials]
  [./constants]
    type = GenericFunctionMaterial
    prop_names = 'kappa_c M L kappa_eta'
    prop_values = '1e-02 1e-02 1e-02 1e-02'
  [../]
  [./local_energy]
    type = DerivativeParsedMaterial
    f_name = f_loc
    args = 'c eta'
    constant_names = 'A   B   C   D   E   F   G'
    constant_expressions = '0.00028 -0.0000165 -0.00017795 0.000194 -0.00036 0.000013231 0.0002'
    function = '(3*eta^2-2*eta^3)*(A*c^2+B*c+C)+(1-(3*eta^2-2*eta^3))*(D*c^2+E*c+F)+G*eta^2*(1-eta)^2'
  [../]
[]

[Postprocessors]
  [./step_size]
    type = TimestepSize
  [../]
  [./evaluations]
    type = NumResidualEvaluations
    mat_prop = f_loc
  [../]
[]

[Preconditioning]
  [./coupled]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  l_max_its = 30
  l_tol = 1e-6
  nl_max_its = 50
  nl_abs_tol = 1e-9
  end_time = 20000
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly ilu          1'
  dt = 100
[]

[Outputs]
  exodus = true
  console = true
  csv = true
  gnuplot = true
  [./console]
    type = Console
    max_rows = 20
  [../]
[]
