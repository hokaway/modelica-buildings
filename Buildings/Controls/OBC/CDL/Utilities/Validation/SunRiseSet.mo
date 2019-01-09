within Buildings.Controls.OBC.CDL.Utilities.Validation;
model SunRiseSet "Test model for the block SunRiseSet"
  extends Modelica.Icons.Example;

  Buildings.Controls.OBC.CDL.Utilities.SunRiseSet sunRiseSetArctic(
    lat=1.2566370614359,
    lon=-1.2566370614359,
    timZon=-18000) "Arctic circle case"
    annotation (Placement(transformation(extent={{-10,50},{10,70}})));
  Buildings.Controls.OBC.CDL.Utilities.SunRiseSet sunRiseSetSf(
    lat=0.6457718232379,
    lon=-2.1293016874331,
    timZon=-28800)
    "using San Francisco as a test example in the northen hemisphere"
    annotation (Placement(transformation(extent={{-10,-30},{10,-10}})));
  Buildings.Controls.OBC.CDL.Utilities.SunRiseSet sunRiseSetAntarctic(
    lat=-1.3089969389957,
    lon=0.99483767363677,
    timZon=14400) "Antarctic circle case"
    annotation (Placement(transformation(extent={{-10,10},{10,30}})));
  Buildings.Controls.OBC.CDL.Utilities.SunRiseSet sunRiseSetSyd(
    lat=-0.59341194567807,
    lon=2.6354471705114,
    timZon=36000) "using Sydney as a test example in the southern hemisphere"
    annotation (Placement(transformation(extent={{-10,-70},{10,-50}})));
equation

annotation (
  experiment(StopTime=31536000, Tolerance=1e-06),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Controls/OBC/CDL/Utilities/Validation/SunRiseSet.mos"
        "Simulate and plot"),
  Documentation(info="<html>
<p>This example includes 4 tests for the SunRiseSet component: 2 normal cases, an arctic and antarctic case. </p>
<p>The normal cases are represented by San Francisco and Sydney, where there are sunrise and sunset every day. </p>
<p>Above the arctic circle (in the north hemisphere), there is no sunset in summer and no sunrise in winter for consecutive days. </p>
<p>Below the antarctic circle (in the south hemisphere), there is no sunrise in summer and no sunset in winter for consecutive days.</p>
</html>",
revisions="<html>
<ul>
<li>
November 27, 2018, by Kun Zhang:<br/>
First implementation.
</li>
</ul>
</html>"));
end SunRiseSet;
