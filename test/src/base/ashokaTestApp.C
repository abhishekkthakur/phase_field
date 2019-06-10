//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "ashokaTestApp.h"
#include "ashokaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

template <>
InputParameters
validParams<ashokaTestApp>()
{
  InputParameters params = validParams<ashokaApp>();
  return params;
}

ashokaTestApp::ashokaTestApp(InputParameters parameters) : MooseApp(parameters)
{
  ashokaTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

ashokaTestApp::~ashokaTestApp() {}

void
ashokaTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  ashokaApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"ashokaTestApp"});
    Registry::registerActionsTo(af, {"ashokaTestApp"});
  }
}

void
ashokaTestApp::registerApps()
{
  registerApp(ashokaApp);
  registerApp(ashokaTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
ashokaTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ashokaTestApp::registerAll(f, af, s);
}
extern "C" void
ashokaTestApp__registerApps()
{
  ashokaTestApp::registerApps();
}
