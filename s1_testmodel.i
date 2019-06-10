[Mesh]
  # generate a 2D, 25nm x 25nm mesh
  type = GeneratedMesh
  dim = 2
  elem_type = QUAD4
  nx = 25
  ny = 25
  nz = 0
  xmin = 0
  xmax = 25
  ymin = 0
  ymax = 25
  zmin = 0
  zmax = 0
  uniform_refine = 2
[]

[Variables]
  [./c]   # Mole fraction of Cr (unitless)
    order = FIRST
    family = LAGRANGE
  [../]
  [./w]   # Chemical potential (eV/mol)
    order = FIRST
    family = LAGRANGE
  [../]
  #[./eta]
  #  order = FIRST
  #  family = LAGRANGE
  #[../]
[]

[ICs]
  # Use a bounding box IC at equilibrium concentrations to make sure the
  # model behaves as expected.
  [./testIC]
    type = RandomIC
    min = 0.1
    max = 0.9
    variable = c
  [../]
[]

[BCs]
  # periodic BC as is usually done on phase-field models
  [./Periodic]
    [./c_bcs]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Kernels]
  # See wiki page "Developing Phase Field Models" for more information on Split
  # Cahn-Hilliard equation kernels.
  # http://mooseframework.org/wiki/PhysicsModules/PhaseField/DevelopingModels/
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
  #[./timederivative]
  #  type = TimeDerivative
  #  variable = eta
  #[../]
  #[./acinterface]
  #  type = ACInterface
  #  variable = eta
  #  kappa_name = kappa_op
  #  mob_name = L
  #[../]
  #[./allencahn]
  #  type = AllenCahn
  #  variable = eta
  #  f_name = f_loc
  #  args = c
  #[../]
[]

[Materials]
  [./constants]
    type = GenericFunctionMaterial
    prop_names = 'kappa_c M'
    prop_values = '8.125e-16*6.24150934e+18*1e+09^2*1e-27
                   2.2841e-26*1e+09^2/6.24150934e+18/1e-27'
                   # kappa_c*eV_J*nm_m^2*d
                   # M*nm_m^2/eV_J/d
  [../]
  [./local_energy]
    # Defines the function for the local free energy density as given in the
    # problem, then converts units and adds scaling factor.
    type = DerivativeParsedMaterial
    f_name = f_loc
    args = c
    constant_names = 'A   B   C   D   E   F   G  eV_J  d'
    constant_expressions = '0.0000260486 0.0000239298 -0.000178164 0.000196227 -0.000365148 0.0000162483 -2.354293e+03 6.24150934e+18 1e-27'
    function = 'eV_J*d*((3*eta^2-2*eta^3)*(A*c^2+B*c+C)+(1-(3*eta^2-2*eta^3))*(D*c^2+E*c+F)+G*eta^2*(1-eta)^2)'
  [../]
[]

[Preconditioning]
  # Preconditioning is required for Newton's method. See wiki page "Solving
  # Phase Field Models" for more information.
  # http://mooseframework.org/wiki/PhysicsModules/PhaseField/SolvingModels/
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
  end_time = 86400   # 1 day. We only need to run this long enough to verify
                     # the model is working properly.
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type
                         -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly
                         ilu          1'
  dt = 100
[]

[Outputs]
  exodus = true
  console = true
[]
