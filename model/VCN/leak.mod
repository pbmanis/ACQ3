TITLE passive  (leak) membrane channel

UNITS {
	(mV) = (millivolt)
	(mA) = (milliamp)
}

NEURON {
	SUFFIX leak
	NONSPECIFIC_CURRENT i
	RANGE g, erev
}

PARAMETER {
	v (mV)
	g = .001	(mho/cm2)
	erev = -65	(mV)
}

ASSIGNED { i	(mA/cm2)}

BREAKPOINT {
	i = g*(v - erev)
}


