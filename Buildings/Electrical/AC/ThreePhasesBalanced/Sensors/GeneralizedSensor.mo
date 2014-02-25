within Buildings.Electrical.AC.ThreePhasesBalanced.Sensors;
model GeneralizedSensor "Sensor for power, voltage and current"

  extends Buildings.Electrical.Interfaces.GeneralizedSensor;
  extends Buildings.Electrical.Interfaces.PartialTwoPort(
    redeclare package PhaseSystem_p = PhaseSystems.OnePhase,
    redeclare package PhaseSystem_n = PhaseSystems.OnePhase,
    redeclare Interfaces.Terminal_n terminal_n(redeclare package PhaseSystem =
          PhaseSystem_n),
    redeclare Interfaces.Terminal_p terminal_p(redeclare package PhaseSystem =
          PhaseSystem_p));
  Modelica.Blocks.Interfaces.RealOutput V(final quantity="ElectricPotential",
                                          final unit="V") "Voltage"           annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={0,-50}),   iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={0,-90})));
  Modelica.Blocks.Interfaces.RealOutput I(final quantity="ElectricCurrent",
                                          final unit="A") "Current"           annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={60,-50}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={60,-90})));
  Modelica.Blocks.Interfaces.RealOutput S[PhaseSystems.OnePhase.n](
                                          each final quantity="Power",
                                          each final unit="W") "Phase powers"             annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-60,-50}),iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-60,-90})));
equation

  V = Buildings.Electrical.PhaseSystems.TwoConductor.systemVoltage(terminal_n.v);
  I = Buildings.Electrical.PhaseSystems.TwoConductor.systemCurrent(terminal_n.i);
  S = Buildings.Electrical.PhaseSystems.TwoConductor.phasePowers_vi(v=terminal_n.v, i=terminal_n.i);

  connect(terminal_n, terminal_p) annotation (Line(
      points={{-100,0},{2,0},{2,0},{100,0}},
      color={0,120,120},
      smooth=Smooth.None));
  annotation (defaultComponentName="sen",
  Documentation(info="<html>
<p>
Ideal sensor that measures power, voltage and current.
The two components of the power <i>S</i> are the active and reactive power.
</p>
</html>", revisions="<html>
<ul>
<li>
July 24, 2013, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
            100}}), graphics));
end GeneralizedSensor;
