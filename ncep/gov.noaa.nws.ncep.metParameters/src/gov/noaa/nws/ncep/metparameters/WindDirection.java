package gov.noaa.nws.ncep.metparameters;

import gov.noaa.nws.ncep.metParameters.parameterConversion.PRLibrary;
import gov.noaa.nws.ncep.metParameters.parameterConversion.PRLibrary.InvalidValueException;
import gov.noaa.nws.ncep.metparameters.MetParameterFactory.DeriveMethod;
 
public class WindDirection extends AbstractMetParameter implements javax.measure.quantity.Angle {

	public WindDirection() {
		 super( UNIT );
	} 

	@DeriveMethod
	AbstractMetParameter derive ( WindDirectionUComp u, WindDirectionVComp v) throws InvalidValueException, NullPointerException{
		if ( u.hasValidValue() && v.hasValidValue() ){     
		     Amount windDrct = PRLibrary.prDrct( u , v );
		     setValue(windDrct);
		}else
			setValueToMissing();
		
		     return this;
	}
	

}
