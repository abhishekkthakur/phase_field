width = 25
[Mesh]
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 200
  ny = 200 #specify 1 for 1-D simulation
  nz = 0
  xmin = 0
  xmax = ${width}
  ymin = 0
  ymax = ${width} #specify 1 for 1-D simulation
  zmin = 0
  zmax = 0
  #uniform_refine = 2
[]

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
  [../]
  [./w]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  [./f_tot]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

[AuxKernels]
  [./f_tot]
    type = TotalFreeEnergy
    variable = f_tot
    kappa_names = kappa_c
    interfacial_vars = c
    f_name = f_loc
  [../]
[]

[ICs]
  [./testIC]
    type = RandomIC
    variable = c
    #function = x/${width}
  [../]
[]

[BCs]
  [./Periodic]
    [./c_bcs]
      auto_direction = 'x y' #When only 'y', then gives 1-D simulation.
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
    prop_values = '8.125e-16*6.24150934e+18*1e+09^2*1e-27
                   2.2841e-26*1e+09^2/6.24150934e+18/1e-27'

  [../]
  [./local_energy]
    type = DerivativeParsedMaterial
    f_name = f_loc
    args = c
    constant_names = 'A   B   C   D   E   F   G  eV_J  d'
    constant_expressions = '-2.446831e+04 -2.827533e+04 4.167994e+03 7.052907e+03
                            1.208993e+04 2.568625e+03 -2.354293e+03
                            6.24150934e+18 1e-27'
    function = 'eV_J*d*(A*c+B*(1-c)+C*c*log(c)+D*(1-c)*log(1-c)+
                E*c*(1-c)+F*c*(1-c)*(2*c-1)+G*(c)*(1-c)*(2*c-1)^2)'
    outputs = exodus
  [../]
[]

#[VectorPostprocessors]
# [./f_loc_sampler]
#   type = LineMaterialRealSampler
#   property = f_loc
#   start = '0 0.5 0'
#   end = '${width} 0.5 0'
#   sort_by = x
# [../]
# [./f_tot_sampler]
#   type = LineValueSampler
#   variable = 'f_tot c'
#   start_point = '0 0.5 0'
#   end_point = '${width} 0.5 0'
#   num_points = 500
#   sort_by = x
# [../]
#[]

#[Postprocessors]
#  [./F_tot]
#    type = ElementIntegralVariablePostprocessor
#    variable = f_tot
#  [../]
#  [./C]
#    type = ElementIntegralVariablePostprocessor
#    variable = c
#  [../]
#  [./c_avg_left_value]
#    type = SideAverageValue
#    variable = c
#    boundary = left
#  [../]
#  [./c_avg_right_value]
#    type = SideAverageValue
#    variable = c
#    boundary = right
#  [../]
#[]

[Preconditioning]
  [./coupled]
    type = SMP
    full = true
  [../]
[]

#[Problem]
#  kernel_coverage_check = false
#  solve = false
#[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  l_max_its = 30
  l_tol = 1e-6
  nl_max_its = 20
  nl_abs_tol = 1e-12

  # petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type
  #                        -sub_pc_type -pc_asm_overlap'
  # petsc_options_value = 'asm      31                  preonly
  #                        ilu          1'

  num_steps = 500

  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    growth_factor = 1.5
    iteration_window = 2
    dt = 10
  [../]
[]

[Outputs]
  exodus = true
  console = true
  csv = true
[]
