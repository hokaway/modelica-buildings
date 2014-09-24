within Buildings.Electrical.AC.ThreePhasesBalanced.Lines;
model Network "Three phases balanced AC network"
  extends Buildings.Electrical.Transmission.BaseClasses.PartialNetwork(
    V_nominal = 480,
    redeclare Interfaces.Terminal_p terminal,
    redeclare Transmission.Grids.TestGrid2Nodes grid,
    redeclare Lines.Line lines(
    redeclare replaceable
        Buildings.Electrical.Transmission.LowVoltageCables.Generic commercialCable=grid.cables));
    Modelica.SIunits.Voltage Vabs[grid.nNodes] "RMS voltage of the grid nodes";
equation
  for i in 1:grid.nLinks loop
    connect(lines[i].terminal_p, terminal[grid.fromTo[i,1]]);
    connect(lines[i].terminal_n, terminal[grid.fromTo[i,2]]);
  end for;

  for i in 1:grid.nNodes loop
    Vabs[i] = Buildings.Electrical.PhaseSystems.OnePhase.systemVoltage(terminal[i].v);
  end for;

  annotation (
    defaultComponentName="net",
    Icon(graphics={             Line(
          points={{-98,-60},{-78,-20},{-58,-60},{-38,-100},{-18,-60}},
          color={0,0,0},
          smooth=Smooth.Bezier),          Line(
          points={{-88,-60},{-68,-20},{-48,-60},{-28,-100},{-8,-60}},
          color={120,120,120},
          smooth=Smooth.Bezier),          Line(
          points={{-78,-60},{-58,-20},{-38,-60},{-18,-100},{2,-60}},
          color={215,215,215},
          smooth=Smooth.Bezier)}), Documentation(revisions="<html>
<ul>
<li>
September 23, 2014, by Marco Bonvini:<br/>
Maintained replaceable the parameter <code>commercialCable</code> when redeclaring 
the type of line.
</li>
<li>
August 25, 2014, by Marco Bonvini:<br/>
Revised documentation.
</li>
</ul>
</html>", info="<html>
<p>
This model represents a generalized electrical AC three phases balanced network.
</p>
<p>
Look at <a href=\"modelica://Buildings.Electrical.Transmission.BaseClasses.PartialNetwork\">
Buildings.Electrical.Transmission.BaseClasses.PartialNetwork</a>
for information about the network model.
</p>
<p>
Look at <a href=\"modelica://Buildings.Electrical.Transmission.Grids.PartialGrid\">
Buildings.Electrical.Transmission.Grids.PartialGrid</a>
for more information about the topology of the network, such as
the number of nodes, how they are connected, and the length of each connection.
</p>
</html>"));
end Network;