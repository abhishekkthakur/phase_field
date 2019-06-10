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
    type = SplitCHParsed
    f_name = f_loc
    kappa_name = kappa_c
    w = w
  [../]
[]

[Materials]
  [./constants]
    type = GenericFunctionMaterial
    prop_names = 'kappa_c M'
    prop_values = '3.5e-16*6.24150934e+18*1e+09^2*1e-27 2.2841e-26*1e+09^2/6.24150934e+18/1e-27'
  [../]
  [./local_energy]
    type = DerivativeParsedMaterial
    f_name = f_loc
    args = c
    constant_names = 'A   B   C   D   E   F   G  eV_J  d'
    constant_expressions = '-2.446831e+04 -2.827533e+04 4.167994e+03 7.052907e+03 1.208993e+04 2.568625e+03 -2.354293e+03
                            6.24150934e+18 1e-27'
    function = 'eV_J*d*(A*c+B*(1-c)+C*c*log(c)+D*(1-c)*log(1-c)+E*c*(1-c)+F*c*(1-c)*(2*c-1)+G*log(c)*log(1-c)*(2*c-1)^2)'
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
  end_time = 86400
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly ilu          1'
  dt = 100
[]

[Outputs]
  exodus = true
  console = true
  csv = true
  gnuplot = true
[]
