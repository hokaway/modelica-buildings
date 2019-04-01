/*
 * Modelica external function to communicate with EnergyPlus.
 *
 * Michael Wetter, LBNL                  2/14/2018
 * Thierry S. Nouidui, LBNL              4/16/2018
 */

#include "FMUZoneExchange.h"
#include "FMUEnergyPlusStructure.h"

#include <stdlib.h>
#include <math.h>

void setGetVariables(
  FMUZone* fmuZon,
  fmi2ValueReference inputValueReferences[],
  fmi2Real inputValues[],
  size_t nInp,
  fmi2ValueReference outputValueReferences[],
  fmi2Real outputValues[],
  size_t nOut)
  {
    fmi2_status_t status;
    writeLog(3, "Setting real variables in EnergyPlus.");
    status = fmi2_import_set_real(
      fmuZon->ptrBui->fmu,
      inputValueReferences,
      nInp,
      inputValues);
    if (status != fmi2OK) {
      ModelicaFormatError("Failed to set variables for building FMU with name %s\n", fmuZon->ptrBui->name);
    }

    writeLog(3, "Getting real variables from EnergyPlus.");
    status = fmi2_import_get_real(
      fmuZon->ptrBui->fmu,
      outputValueReferences,
      nOut,
      outputValues);
    if (status != fmi2OK) {
      ModelicaFormatError("Failed to get variables for building FMU with name %s\n", fmuZon->ptrBui->name);
    }
  }

void FMUZoneExchange(
  void* object,
  int initialCall,
  double T,
  double X,
  double mInlets_flow,
  double TAveInlet,
  double QGaiRad_flow,
  double time,
  double* TRad,
  double* QConSen_flow,
  double* dQConSen_flow,
  double* QLat_flow,
  double* QPeo_flow,
  double* tNext){

  FMUZone* zone = (FMUZone*) object;
  fmi2Real inputValues[ZONE_N_INP];
  fmi2Real outputValues[ZONE_N_OUT];
  fmi2_event_info_t eventInfo;
  fmi2Status status;

  const double dT = 0.01; /* Increment for derivative approximation */
  double QConSenPer_flow;

  double AFlo;
  double V;
  double mSenFac;

  FMUZone* tmpZon;

  writeFormatLog(3, "Exchanging data with EnergyPlus in FMUZoneExchange at t = %.2f, initialCall = %d.",
    time, initialCall);

  tmpZon=(FMUZone*)zone->ptrBui->zones[zone->index-1];
  /* Time need to be guarded against rounding error */
  /* *tNext = round((floor(time/3600.0)+1) * 3600.0); */

  if (! tmpZon->isInstantiated){
    /* This zone has not been initialized because the simulator optimized away the call to initialize().
       Hence, we intialize it now.
    */
    FMUZoneInstantiate(object, time, &AFlo, &V, &mSenFac);
  }

  if (initialCall){
    /* Enter initialization mode */
    writeFormatLog(3, "Enter initialization mode of FMU with T = %.f.", T);
    status = fmi2_import_enter_initialization_mode(zone->ptrBui->fmu);
    writeLog(3, "Returned from enter initialization mode of FMU.");
    if( status != fmi2_status_ok ){
      ModelicaFormatError("Failed to enter initialization mode for FMU with name %s.",  zone->ptrBui->fmuAbsPat);
    }
  }
  else{
    writeLog(3, "Setting time in EnergyPlus.");
    status = fmi2_import_set_time(zone->ptrBui->fmu, time);
    writeLog(3, "Returned from setting time in EnergyPlus.");
    if ( status != fmi2OK ) {
      ModelicaFormatError("Failed to set time in building FMU with name %s.",
      zone->ptrBui->name);
    }
  }

  /* fixme: check if we need to add call to fmi2CompletedIntegratorStep */

  /* Set input values, which are of the order below
     const char* inpNames[] = {"T", "X", "mInlets_flow", "TAveInlet", "QGaiRad_flow"};
  */
  inputValues[1] = X/(1.-X); /* Conversion from kg/kg_total_air to kg/kg_dry_air */
  inputValues[2] = mInlets_flow;
  inputValues[3] = TAveInlet;
  inputValues[4] = QGaiRad_flow;

  /* Forward difference for QConSen_flow */
  inputValues[0] = T - 273.15 + dT;

  writeFormatLog(3, "Input to fmu: TAir = %.2f; \t QGaiRad_flow = %.2f",
    inputValues[0], inputValues[4]);

  setGetVariables(zone,
    tmpZon->inputValueReferences, inputValues, ZONE_N_INP,
    tmpZon->outputValueReferences, outputValues, ZONE_N_OUT);
  QConSenPer_flow=outputValues[1];
  inputValues[0] = T - 273.15;
  setGetVariables(zone,
    tmpZon->inputValueReferences, inputValues, ZONE_N_INP,
    tmpZon->outputValueReferences, outputValues, ZONE_N_OUT);

  /* Assign output values, which are of the order below
     const char* outNames[] = {"TRad", "QConSen_flow", "QLat_flow", "QPeo_flow"};
  */
  *TRad = outputValues[0] + 273.15;
  *QConSen_flow = outputValues[1];
  *QLat_flow = outputValues[2];
  *QPeo_flow = outputValues[3];
  *dQConSen_flow = (QConSenPer_flow-*QConSen_flow)/dT;

  writeFormatLog(3, "After time step: TRad = %.2f; \t QCon = %.2f;\t QLat = %.2f", *TRad, *QConSen_flow,
    *QLat_flow);

  if (initialCall){
    writeLog(3, "Enter exit initialization mode of FMU.");
    status = fmi2_import_exit_initialization_mode(zone->ptrBui->fmu);
    if( status != fmi2_status_ok ){
      ModelicaFormatError("Failed to exit initialization mode for FMU with name %s.",  zone->ptrBui->fmuAbsPat);
    }
  }

  /* Get next event time */
  status = do_event_iteration(zone->ptrBui->fmu, &eventInfo);
  /* status = fmi2_import_new_discrete_states(zone->ptrBui->fmu, &eventInfo);*/
  if (status != fmi2OK) {
    ModelicaFormatError("Failed during call to fmi2NewDiscreteStates for building FMU with name %s.",
    zone->ptrBui->name);
  }
  if(eventInfo.terminateSimulation == fmi2True){
    ModelicaFormatError("EnergyPlus requested to terminate the simulation for building = %s, zone = %s, time = %f.",
    zone->ptrBui->name, zone->name, time);
  }
  if(eventInfo.nextEventTimeDefined == fmi2False){
    ModelicaFormatError("Expected EnergyPlus to set nextEventTimeDefined = true in FMU =%s, zone = %s, time = %f.",
      zone->ptrBui->name, zone->name, time);
  }
  else{
    *tNext = eventInfo.nextEventTime;
    writeFormatLog(3, "Requested next event time at %.2f: %.2f\n", time, *tNext);
    if (*tNext <= time + 1E-6){
      ModelicaFormatError("EnergyPlus requested at time = %f a next event time of %f for building = %s, zone = %s. Zero time steps are not supported. Check with support.",
      time, *tNext, zone->ptrBui->name, zone->name);
    }
  }

  writeFormatLog(3, "Returning from FMUZoneExchange with nextEventTime = %.2f.", *tNext);
  return;
}