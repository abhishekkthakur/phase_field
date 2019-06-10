#include "ashokaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

template <>
InputParameters
validParams<ashokaApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

ashokaApp::ashokaApp(InputParameters parameters) : MooseApp(parameters)
{
  ashokaApp::registerAll(_factory, _action_factory, _syntax);
}

ashokaApp::~ashokaApp() {}

void
ashokaApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"ashokaApp"});
  Registry::registerActionsTo(af, {"ashokaApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
ashokaApp::registerApps()
{
  registerApp(ashokaApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
ashokaApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ashokaApp::registerAll(f, af, s);
}
extern "C" void
ashokaApp__registerApps()
{
  ashokaApp::registerApps();
}
