package gov.noaa.nws.ncep.ui.nsharp.display.rsc;
/**
 * 
 * 
 * This code has been developed by the NCEP-SIB for use in the AWIPS2 system.
 * 
 * <pre>
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    	Engineer    Description
 * -------		------- 	-------- 	-----------
 * 04/23/2012	229			Chin Chen	Initial coding
 *
 * </pre>
 * 
 * @author Chin Chen
 * @version 1.0
 */

import gov.noaa.nws.ncep.edex.common.sounding.NcSoundingLayer;
import gov.noaa.nws.ncep.ui.nsharp.NsharpConstants;
import gov.noaa.nws.ncep.ui.nsharp.NsharpLineProperty;
import gov.noaa.nws.ncep.ui.nsharp.NsharpShapeAndLineProperty;
import gov.noaa.nws.ncep.ui.nsharp.NsharpSoundingElementStateProperty;
import gov.noaa.nws.ncep.ui.nsharp.NsharpStationInfo;
import gov.noaa.nws.ncep.ui.nsharp.NsharpStationStateProperty;
import gov.noaa.nws.ncep.ui.nsharp.NsharpTimeLineStateProperty;
import gov.noaa.nws.ncep.ui.nsharp.NsharpWxMath;
import gov.noaa.nws.ncep.ui.nsharp.background.NsharpGenericPaneBackground;
import gov.noaa.nws.ncep.ui.nsharp.background.NsharpIcingPaneBackground;
import gov.noaa.nws.ncep.ui.nsharp.background.NsharpSkewTPaneBackground;
import gov.noaa.nws.ncep.ui.nsharp.background.NsharpTurbulencePaneBackground;
import gov.noaa.nws.ncep.ui.nsharp.display.NsharpEditor;
import gov.noaa.nws.ncep.ui.nsharp.display.NsharpSkewTPaneDescriptor;
import gov.noaa.nws.ncep.ui.nsharp.display.rsc.NsharpResourceHandler.ParcelData;
import gov.noaa.nws.ncep.ui.nsharp.natives.NsharpNative;
import gov.noaa.nws.ncep.ui.nsharp.natives.NsharpNative.NsharpLibrary._lplvalues;
import gov.noaa.nws.ncep.ui.nsharp.natives.NsharpNative.NsharpLibrary._parcel;
import gov.noaa.nws.ncep.ui.nsharp.natives.NsharpNativeConstants;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;

import com.raytheon.uf.common.sounding.WxMath;
import com.raytheon.uf.common.status.UFStatus;
import com.raytheon.uf.common.status.UFStatus.Priority;
import com.raytheon.uf.common.time.DataTime;
import com.raytheon.uf.viz.core.IExtent;
import com.raytheon.uf.viz.core.IGraphicsTarget;
import com.raytheon.uf.viz.core.IGraphicsTarget.HorizontalAlignment;
import com.raytheon.uf.viz.core.IGraphicsTarget.LineStyle;
import com.raytheon.uf.viz.core.IGraphicsTarget.PointStyle;
import com.raytheon.uf.viz.core.IGraphicsTarget.TextStyle;
import com.raytheon.uf.viz.core.IGraphicsTarget.VerticalAlignment;
import com.raytheon.uf.viz.core.PixelExtent;
import com.raytheon.uf.viz.core.drawables.IFont;
import com.raytheon.uf.viz.core.drawables.IShadedShape;
import com.raytheon.uf.viz.core.drawables.IWireframeShape;
import com.raytheon.uf.viz.core.drawables.PaintProperties;
import com.raytheon.uf.viz.core.exception.VizException;
import com.raytheon.uf.viz.core.rsc.AbstractResourceData;
import com.raytheon.uf.viz.core.rsc.LoadProperties;
import com.raytheon.viz.core.graphing.LineStroke;
import com.raytheon.viz.core.graphing.WGraphics;
import com.raytheon.viz.core.graphing.WindBarbFactory;
import com.sun.jna.ptr.FloatByReference;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.LineString;

public class NsharpSkewTPaneResource extends NsharpAbstractPaneResource{
	private NsharpSkewTPaneBackground skewTBackground;
	private NsharpIcingPaneBackground icingBackground;
	private NsharpTurbulencePaneBackground turbBackground;
	private int currentGraphMode= NsharpConstants.GRAPH_SKEWT;
	private int skewtWidth = NsharpConstants.SKEWT_WIDTH;
	private int skewtHeight = NsharpConstants.SKEWT_HEIGHT;
	private int skewtXOrig = NsharpConstants.SKEWT_X_ORIG;
	private int skewtYOrig = NsharpConstants.SKEWT_Y_ORIG;
	private int skewtXEnd = NsharpConstants.SKEWT_X_END;
	private int skewtYEnd = NsharpConstants.SKEWT_Y_END;
	private float xRatio=1;
	private float yRatio=1;
	private String sTemperatureC= "";
	private String sTemperatureF = "";
	private String sThetaInK = "";
	private String sWThetaInK = "";
	private String sEThetaInK="";
	private String sMixingRatio = "";
	private String sPressure = "";
	private double dPressure;	
	private IWireframeShape heightMarkRscShape=null;
	private IWireframeShape wetBulbTraceRscShape = null;
	private IWireframeShape vtempTraceCurveRscShape = null;
	private IShadedShape cloudFMShape = null;
	private IWireframeShape cloudFMLabelShape = null;
	private IShadedShape cloudCEShape = null;
	private List<IWireframeShape> parcelTraceRscShapeList = new ArrayList<IWireframeShape>();
	private List<NsharpShapeAndLineProperty>pressureTempRscShapeList  = new ArrayList<NsharpShapeAndLineProperty>();
	//ICING wireframe shape
	private IWireframeShape icingTempShape = null;
	private IWireframeShape icingRHShape = null;
	private IWireframeShape icingEPIShape = null;
	//Turbulence wireframe shape
	private IWireframeShape turbLnShape = null;
	private IWireframeShape turbWindShearShape = null;
	public int TEMP_TYPE = 1;
	public int DEWPOINT_TYPE = 2;
	private int currentTempCurveType;
	private Coordinate interactiveTempPointCoordinate;
	private boolean plotInteractiveTemp= false;
	//private double mycurrentZoomLevel=1;
	private boolean cursorInSkewT = false;
	private static int CURSER_FONT_INC_STEP = 3;
	private static int CURSER_FONT_10 =10;
	private static int CURSER_STRING_OFF =CURSER_FONT_10+ 5*CURSER_FONT_INC_STEP;
	private int curseToggledFontLevel= CURSER_FONT_10; //0:default 1:large 2:turn off display
	public NsharpSkewTPaneResource(AbstractResourceData resourceData,
			LoadProperties loadProperties, NsharpSkewTPaneDescriptor desc) {
		super(resourceData, loadProperties, desc);
		skewTBackground = new NsharpSkewTPaneBackground((NsharpSkewTPaneDescriptor)descriptor);
		icingBackground = new NsharpIcingPaneBackground((NsharpSkewTPaneDescriptor)descriptor);
		turbBackground = new NsharpTurbulencePaneBackground((NsharpSkewTPaneDescriptor)descriptor);
		//verticalWindBackground = new NsharpSKEWTBackground(descriptor);
		this.dataTimes = new ArrayList<DataTime>();
	}

	@Override
	protected void disposeInternal() {	
		skewTBackground.disposeInternal(); 
		icingBackground.disposeInternal();
		turbBackground.disposeInternal();
		skewTBackground = null;
		icingBackground = null;
		turbBackground = null;
		disposeRscWireFrameShapes();
		pressureTempRscShapeList=null;
		parcelTraceRscShapeList = null;
		super.disposeInternal();
	}
	private void plotPressureTempEditPoints(IGraphicsTarget target, 
            WGraphics world, RGB color, int type, List<NcSoundingLayer> soundingLys) throws VizException {
    	double maxPressure = NsharpWxMath.reverseSkewTXY(new Coordinate(0, world
                .getWorldYmax())).y;
        double minPressure = NsharpWxMath.reverseSkewTXY(new Coordinate(0, world
                .getWorldYmin())).y;
        PointStyle ps = PointStyle.CIRCLE;
    	for (NcSoundingLayer layer : soundingLys) {
        	double t;
        	if(type == TEMP_TYPE)
        		t = layer.getTemperature();
        	else if (type == DEWPOINT_TYPE)
        		t = layer.getDewpoint();
        	else
        		break;
            double pressure = layer.getPressure();
            if (t != INVALID_DATA  && pressure >= minPressure
                    && pressure <= maxPressure) {

                Coordinate c1 = NsharpWxMath.getSkewTXY(pressure, t);
                
                c1.x = world.mapX(c1.x);
                c1.y = world.mapY(c1.y);
                
                target.drawPoint(c1.x, c1.y, 0.0, color, ps);
                
            }
        }
    }
    /*
     * This function mostly follow display_effective_layer() of xwvid1.c     */
    @SuppressWarnings("deprecation")
	private void drawEffectiveLayerLines(IGraphicsTarget target) throws VizException{
    	
    	FloatByReference topPF= new FloatByReference(0);
		FloatByReference botPF= new FloatByReference(0);
    	nsharpNative.nsharpLib.get_effectLayertopBotPres(topPF, botPF);
    	if(botPF.getValue() < 1 ) return;
    	double dispX0;
    	double dispX1;
		double dispX2;
		double dispX3;
    	IExtent ext = getDescriptor().getRenderableDisplay().getExtent();
		dispX0 = ext.getMinX() + ext.getWidth()/5;
		dispX1 = dispX0+ 20 * zoomLevel* xRatio;
		dispX2 = dispX1+ 20 * zoomLevel* xRatio;
		dispX3 = dispX2+ 20 * zoomLevel* xRatio;
    	String botStr, topStr;
    	float aglTop, aglBot;
    	aglTop = nsharpNative.nsharpLib.agl(nsharpNative.nsharpLib.ihght(topPF.getValue()));
    	aglBot = nsharpNative.nsharpLib.agl(nsharpNative.nsharpLib.ihght(botPF.getValue()));
    	// Draw effective sfc level 
    	if (aglBot < 1)
		{ 
    		botStr = "SFC";
		}
		else
		{  
			botStr = String.format( "%.0fm", aglBot);
		}
    	double y = world.mapY(NsharpWxMath.getSkewTXY(botPF.getValue(), 10).y);
    	target.drawLine( dispX1, y, 0.0, dispX3, y, 0.0,
				NsharpConstants.color_cyan_md, 2);
		target.drawString(font10,botStr, dispX3,
				y, 0.0, TextStyle.NORMAL,
				NsharpConstants.color_cyan_md, HorizontalAlignment.LEFT,
				VerticalAlignment.MIDDLE, null);
    	// Draw effective top level		
    	topStr = String.format( "%.0fm", aglTop);
    	double y1 = world.mapY(NsharpWxMath.getSkewTXY(topPF.getValue(), 10).y);
    	target.drawLine( dispX1, y1, 0.0,  dispX3, y1, 0.0,
				NsharpConstants.color_cyan_md, 2);
    	if(aglTop > aglBot){
    		target.drawString(font10,topStr, dispX3,
    				y1, 0.0, TextStyle.NORMAL,
    				NsharpConstants.color_cyan_md, HorizontalAlignment.LEFT,
    				VerticalAlignment.MIDDLE, null);
    		//System.out.println("aglbot="+aglBot+" agltop="+aglTop);
    	}
		
    	// Draw connecting line
		target.drawLine( dispX2, y, 0.0,  dispX2, y1, 0.0,
				NsharpConstants.color_cyan_md, 2);
    	// Compute and display effective helicity
    	topPF.setValue(0); // just a placeholder
    	botPF.setValue(0);
    	float helicity = nsharpNative.nsharpLib.helicity(aglBot,aglTop, rscHandler.getSmWindDir(),rscHandler.getSmWindSpd(), topPF, botPF);
    	String helicityStr = String.format("%4.0f m%cs%c", helicity,NsharpConstants.SQUARE_SYMBOL, NsharpConstants.SQUARE_SYMBOL);

    	//draw kelicity
    	target.drawString(font10,helicityStr, dispX0,
				y1-10*yRatio, 0.0, TextStyle.NORMAL,
				NsharpConstants.color_cyan_md, HorizontalAlignment.LEFT,
				VerticalAlignment.MIDDLE, null);
    }
    
    @SuppressWarnings("deprecation")
	private void drawLclLine(IGraphicsTarget target) throws VizException{
    	 	//System.out.println("drawLclLine called define_parcel pType="+currentParcel+" pre="+ currentParcelLayerPressure);
    	double	 dispX1;
		double dispX2;
		IExtent ext = getDescriptor().getRenderableDisplay().getExtent();
		dispX1 = ext.getMaxX() -ext.getWidth()/3;
		dispX2 = dispX1+ 40 * zoomLevel* xRatio;
    	nsharpNative.nsharpLib.define_parcel(rscHandler.getCurrentParcel(), rscHandler.getCurrentParcelLayerPressure());
    	_lplvalues lpvls = new _lplvalues();
		nsharpNative.nsharpLib.get_lpvaluesData(lpvls);

		float sfctemp, sfcdwpt, sfcpres;
		sfctemp = lpvls.temp;
		sfcdwpt = lpvls.dwpt;
		sfcpres = lpvls.pres;
		// get parcel data by calling native nsharp parcel() API. value is returned in pcl 
		_parcel pcl = new _parcel();
		nsharpNative.nsharpLib.parcel( -1.0F, -1.0F, sfcpres, sfctemp, sfcdwpt, pcl);
    	//draw LCL line
    	float lcl = nsharpNative.nsharpLib.agl(nsharpNative.nsharpLib.ihght(pcl.lclpres ));
		if(lcl != NsharpNativeConstants.NSHARP_LEGACY_LIB_INVALID_DATA){
			double pressure = nsharpNative.nsharpLib.ipres(lcl+(int)(soundingLys.get(0).getGeoHeight()));
			//System.out.println("lcl= " + lcl + " lclpres ="+pcl.lclpres +" pressure="+ pressure);
        	double y = world.mapY(NsharpWxMath.getSkewTXY(pressure, 10).y);
        	target.drawLine( dispX1/*world.mapX(NsharpConstants.right)-220 */, y, 0.0,dispX2/* world.mapX(NsharpConstants.right) -180*/, y, 0.0,
        			NsharpConstants.color_green, 2);
        	target.drawString(font10, "LCL",dispX1 /*world.mapX(NsharpConstants.right)-220*/,
        			y+5*yRatio, 0.0, TextStyle.NORMAL,
        			NsharpConstants.color_green, HorizontalAlignment.LEFT,
        			VerticalAlignment.MIDDLE, null);
		}
		//draw LFC line
		if(pcl.lclpres!=pcl.lfcpres){
			float lfc = nsharpNative.nsharpLib.agl(nsharpNative.nsharpLib.ihght(pcl.lfcpres ));
			if(lfc != NsharpNativeConstants.NSHARP_LEGACY_LIB_INVALID_DATA){
				double pressure = nsharpNative.nsharpLib.ipres(lfc+(int)(soundingLys.get(0).getGeoHeight()));
				//System.out.println("lfcpres ="+pcl.lfcpres +" pressure="+ pressure);
				double y = world.mapY(NsharpWxMath.getSkewTXY(pressure, 10).y);
				target.drawLine( dispX1, y, 0.0,  dispX2, y, 0.0,
						NsharpConstants.color_yellow, 2);
				target.drawString(font10, "LFC", dispX1,
						y, 0.0, TextStyle.NORMAL,
						NsharpConstants.color_yellow, HorizontalAlignment.RIGHT,
						VerticalAlignment.MIDDLE, null);
			}
		}
		// draw EL line
		if(pcl.lclpres!=pcl.elpres && pcl.elpres!=pcl.lfcpres){
			float el = nsharpNative.nsharpLib.agl(nsharpNative.nsharpLib.ihght(pcl.elpres ));
			if(el != NsharpNativeConstants.NSHARP_LEGACY_LIB_INVALID_DATA){
				double pressure = nsharpNative.nsharpLib.ipres(el+(int)(soundingLys.get(0).getGeoHeight()));
				//System.out.println("elpres ="+pcl.elpres +" pressure="+ pressure);
				double y = world.mapY(NsharpWxMath.getSkewTXY(pressure, 10).y);
				target.drawLine( dispX1, y, 0.0,  dispX2, y, 0.0,
						NsharpConstants.color_red, 2);
				target.drawString(font10, "EL", dispX1,
						y-10*yRatio, 0.0, TextStyle.NORMAL,
						NsharpConstants.color_red, HorizontalAlignment.LEFT,
						VerticalAlignment.MIDDLE, null);
			}
		}
		// draw FGZ line
		FloatByReference fValue= new FloatByReference(0);
		float fgzm = nsharpNative.nsharpLib.agl(nsharpNative.nsharpLib.ihght(nsharpNative.nsharpLib.temp_lvl( 0, fValue )));
		float fgzft = nsharpNative.nsharpLib.mtof(fgzm);
		if(nsharpNative.nsharpLib.qc(fgzft)==1) {
			double pressure = nsharpNative.nsharpLib.ipres(fgzm+(int)(soundingLys.get(0).getGeoHeight()));
			//System.out.println("elpres ="+pcl.elpres +" pressure="+ pressure);
        	double y = world.mapY(NsharpWxMath.getSkewTXY(pressure, 10).y);
        	target.drawLine( dispX1, y, 0.0,  dispX2, y, 0.0,
        			NsharpConstants.color_cyan, 2);
        	String textStr = "FGZ= %.0f'";
			textStr = String.format(textStr,fgzft);
        	target.drawString(font10, textStr, dispX1,
        			y-10*yRatio, 0.0, TextStyle.NORMAL,
        			NsharpConstants.color_cyan, HorizontalAlignment.LEFT,
        			VerticalAlignment.MIDDLE, null);
		}
		// draw -20Cline
		float h20m = nsharpNative.nsharpLib.agl(nsharpNative.nsharpLib.ihght(nsharpNative.nsharpLib.temp_lvl( -20, fValue )));
		float h20ft = nsharpNative.nsharpLib.mtof(h20m);
		if(nsharpNative.nsharpLib.qc(h20ft)==1) {
			double pressure = nsharpNative.nsharpLib.ipres(h20m+(int)(soundingLys.get(0).getGeoHeight()));
			//System.out.println("elpres ="+pcl.elpres +" pressure="+ pressure);
        	double y = world.mapY(NsharpWxMath.getSkewTXY(pressure, -20).y);
        	//double x = world.mapX(NsharpWxMath.getSkewTXY(pressure, -20).x);
        	target.drawLine( dispX1, y, 0.0,  dispX2, y, 0.0,
        			NsharpConstants.color_cyan, 2);
        	String textStr = "-20C= %.0f'";
			textStr = String.format(textStr,h20ft);
        	target.drawString(font10, textStr, dispX1,
        			y-10*yRatio, 0.0, TextStyle.NORMAL,
        			NsharpConstants.color_cyan, HorizontalAlignment.LEFT,
        			VerticalAlignment.MIDDLE, null);
		}
		// draw -30Cline
		float h30m = nsharpNative.nsharpLib.agl(nsharpNative.nsharpLib.ihght(nsharpNative.nsharpLib.temp_lvl( -30, fValue )));
		float h30ft = nsharpNative.nsharpLib.mtof(h30m);
		if(nsharpNative.nsharpLib.qc(h30ft)==1) {
			double pressure = nsharpNative.nsharpLib.ipres(h30m+(int)(soundingLys.get(0).getGeoHeight()));
			//System.out.println("elpres ="+pcl.elpres +" pressure="+ pressure);
        	double y = world.mapY(NsharpWxMath.getSkewTXY(pressure, 10).y);
        	target.drawLine( dispX1, y, 0.0,  dispX2, y, 0.0,
        			NsharpConstants.color_cyan, 2);
        	String textStr = "-30C= %.0f'";
			textStr = String.format(textStr,h30ft);
        	target.drawString(font10, textStr, dispX1,
        			y-10*yRatio, 0.0, TextStyle.NORMAL,
        			NsharpConstants.color_cyan, HorizontalAlignment.LEFT,
        			VerticalAlignment.MIDDLE, null);
		}
    }
	@SuppressWarnings("deprecation")
	private void plotNsharpInteractiveTemp(IGraphicsTarget target, double zoomLevel,
            WGraphics world, RGB color) throws VizException {
		if(soundingLys.size() < 4)
			return;
		//double inPressure = soundingLys.get(currentSoundingLayerIndex).getPressure();
		double aboveLayerPressure, belowLayerPressure;
		double aboveLayerT=0, aboveLayerD=0, belowLayerT=0, belowLayerD=0;
		int aboveLayerIndex, belowLayerIndex;
		double plotAboveT, plotBelowT;
		if(currentSoundingLayerIndex ==0){
			aboveLayerIndex = currentSoundingLayerIndex;
			belowLayerIndex = currentSoundingLayerIndex+1;
		}
		else if(currentSoundingLayerIndex == soundingLys.size()-1 ){
			belowLayerIndex = currentSoundingLayerIndex;
			aboveLayerIndex = currentSoundingLayerIndex-1;
		}
		else{
			belowLayerIndex = currentSoundingLayerIndex + 1;
			aboveLayerIndex = currentSoundingLayerIndex - 1;
		}
		aboveLayerPressure = soundingLys.get(aboveLayerIndex).getPressure();
		aboveLayerT = soundingLys.get(aboveLayerIndex).getTemperature();
		aboveLayerD = soundingLys.get(aboveLayerIndex).getDewpoint();
		belowLayerPressure = soundingLys.get(belowLayerIndex).getPressure();
		belowLayerT = soundingLys.get(belowLayerIndex).getTemperature();
		belowLayerD = soundingLys.get(belowLayerIndex).getDewpoint();
		
		if(currentTempCurveType == TEMP_TYPE){
			plotAboveT = aboveLayerT;
			plotBelowT = belowLayerT;

		}
		else{
			plotAboveT = aboveLayerD;
			plotBelowT = belowLayerD;

		}
		Coordinate c1 = NsharpWxMath.getSkewTXY(aboveLayerPressure, plotAboveT);                
		c1.x = world.mapX(c1.x);
		c1.y = world.mapY(c1.y);
		target.drawLine(c1.x, c1.y, 0.0, interactiveTempPointCoordinate.x, interactiveTempPointCoordinate.y, 0.0, color,
				commonLinewidth, LineStyle.DASHED);
		c1 = NsharpWxMath.getSkewTXY(belowLayerPressure,plotBelowT);            
		c1.x = world.mapX(c1.x);
		c1.y = world.mapY(c1.y);
		target.drawLine(c1.x, c1.y, 0.0, interactiveTempPointCoordinate.x, interactiveTempPointCoordinate.y, 0.0, color,
				commonLinewidth, LineStyle.DASHED);
		//System.out.println("In pressure="+ inPressure+ " above P="+aboveLayerPressure+ " below P="+belowLayerPressure);
	}
   /**
     * 
     * Draws Wind barb and wind speed vs height into box
     * This function followed algorithm in plot_barbs (void) at xwvid1.c
     * to choose wind bulb for drawing around every 400m
     * 
     */
    private void drawNsharpWindBarb(IGraphicsTarget target, double zoomLevel,
            WGraphics world,  RGB icolor, List<NcSoundingLayer> sndLys, double xPosition, double botPress)throws VizException {
        ArrayList<List<LineStroke>> windList = new ArrayList<List<LineStroke>>();

        double windX = xPosition;
        float lastHeight = -999;
        double windY=0;
        double barbScaleFactorx=1, barbScaleFactory=1;
        //System.out.println("zoom="+zoomLevel +"world viewYmin="+world.getViewYmin()+" viewYmax="+world.getViewYmax()+" wolrdYmin="+ world.getWorldYmin()+" wolrdYmax="+ world.getWorldYmax()
        //		+"world viewXmin="+world.getViewXmin()+" viewXmax="+world.getViewXmax()+" wolrdXmin="+ world.getWorldXmin()+" wolrdXmax="+ world.getWorldXmax());
        for (NcSoundingLayer layer : sndLys) {
            float pressure = layer.getPressure();
            float spd = layer.getWindSpeed();
            float dir = layer.getWindDirection();
            if ( pressure < botPress || spd < 0 ) {
                continue;
            }
            if(spd > 140)
            	spd = 140;
            if ((layer.getGeoHeight() - lastHeight) < graphConfigProperty.getWindBarbDistance()*zoomLevel){
            	
            	continue;
            }

            // Get the vertical ordinate.
            if(currentGraphMode== NsharpConstants.GRAPH_SKEWT)
            	windY = NsharpWxMath.getSkewTXY(pressure, 0).y;
            else if(currentGraphMode== NsharpConstants.GRAPH_ICING ){
            	//Chin:Y axis (pressure) is scaled using log scale and increaing downward
            	//WorldYmin= at pressure 1000,its value actually is 1000 (max), wolrdYmax = at pressure 300, its value is 825 (min)
            	windY = world.getWorldYmax() + (world.getWorldYmin()-icingBackground.toLogScale(pressure));
            	barbScaleFactorx = 2.5;
            	barbScaleFactory= 3.5;//experimental value: depends on the world coordinate size set
            }else if( currentGraphMode== NsharpConstants.GRAPH_TURB){
            	//Chin:Y axis (pressure) is scaled using log scale and increaing downward
            	//WorldYmin= at pressure 1000,its value actually is 1000 (max), wolrdYmax = at pressure 300, its value is 825 (min)
            	windY = world.getWorldYmax() + (world.getWorldYmin()-turbBackground.toLogScale(pressure));
            	barbScaleFactorx = .23;//experimental value: depends on the world coordinate size set
            	barbScaleFactory=5.5;
            }
            else
            	continue;
            		
            List<LineStroke> barb = WindBarbFactory.getWindGraphics((double) (spd), (double) dir);
            if (barb != null) {
               // WindBarbFactory.scaleBarb(barb, zoomLevel*barbScaleFactor);
                for (LineStroke stroke : barb) {
                    stroke.scale(barbScaleFactorx, barbScaleFactory);
                }
                //System.out.println("pressure="+pressure+" windX="+windX+" windY="+windY);
                WindBarbFactory.translateBarb(barb, windX, windY);
                windList.add(barb);
            }
             lastHeight = layer.getGeoHeight();
        }

        for (List<LineStroke> barb : windList) {
        	//System.out.println("barb");
        	for (LineStroke stroke : barb) {
        		//System.out.println("p1x="+(int)stroke.getPoint().x+" p1y="+(int)stroke.getPoint().y);
        		stroke.render(target, world, icolor);
        	}
        }
    }
    @SuppressWarnings("deprecation")
	private void drawNsharpSkewtCursorData(IGraphicsTarget target) throws VizException{
    	IFont myFont;
    	myFont = target.initializeFont("Monospace", curseToggledFontLevel, null);
    	myFont.setSmoothing(false);
    	myFont.setScaleFont(false);
    	
    	Coordinate c = NsharpWxMath.reverseSkewTXY(world.unMap(cursorCor.x, cursorCor.y));
    	//System.out.println("Cusrso.x="+cursorCor.x+" Cusrso.y="+cursorCor.y);
    	//System.out.println("Skewt.x="+c.x+" Skewt.y="+c.y);
		double p_mb = c.y;
		double temp = c.x;
		float htFt, htM, relh=-1;
		String curStrFormat, curStrFormat1;
		String curStr, curStr1;//, curStr2,curStr3;
		VerticalAlignment vAli;
		HorizontalAlignment hAli;
		
		//curStr3 = rscHandler.getPickedStnInfoStr()+"\n";

		htM = nsharpNative.nsharpLib.agl(nsharpNative.nsharpLib.ihght((float)p_mb));
		htFt= nsharpNative.nsharpLib.mtof(htM);
		if (nsharpNative.nsharpLib.itemp((float)p_mb) > -9998.0 && nsharpNative.nsharpLib.idwpt((float)p_mb) > -9998.0){
			FloatByReference parm= new FloatByReference(0);
			relh= nsharpNative.nsharpLib.relh((float)p_mb, parm);
			curStrFormat= "%4.0fmb  %5.0fft/%.0fm agl  %2.0f%%\n";
			curStr = String.format(curStrFormat, p_mb,htFt,htM,relh);
		}
		else{
			curStrFormat= "%4.0fmb  %5.0fft/%.0fm agl\n";
			curStr = String.format(curStrFormat, p_mb,htFt,htM);
		}
		curStrFormat1 = "%s/%s %4.1f/%4.1f%cC  %4.0f/%.0f kt\n";
		curStr1 = String.format(curStrFormat1,sTemperatureC,sTemperatureF,  nsharpNative.nsharpLib.itemp((float)p_mb),
				nsharpNative.nsharpLib.idwpt((float)p_mb),NsharpConstants.DEGREE_SYMBOL, nsharpNative.nsharpLib.iwdir((float)p_mb),
				nsharpNative.nsharpLib.iwspd((float)p_mb));

		//String tempS= String.format("%5.1f%cC ",temp,NsharpConstants.DEGREE_SYMBOL);
		//curStr2 =sThetaInK+" "+sWThetaInK+" "+sEThetaInK+"\n";

		//Adjust string plotting position
		if(cursorCor.x < skewtXOrig + (200/currentZoomLevel)*xRatio){
			hAli = HorizontalAlignment.LEFT;
		} 
		else {
			hAli = HorizontalAlignment.RIGHT;
		}
		if(cursorCor.y > skewtYOrig + (50/currentZoomLevel)*yRatio){
			vAli = VerticalAlignment.BOTTOM;
		} 
		else {
			vAli = VerticalAlignment.TOP;
		}
		//vAli = VerticalAlignment.BOTTOM;
		target.drawString(myFont,curStr+curStr1/*+curStr2+curStr3*/, cursorCor.x,
				cursorCor.y, 0.0, TextStyle.NORMAL,
				NsharpConstants.color_yellow, hAli,
				vAli, null);
		myFont.dispose();
    }

    @SuppressWarnings("deprecation")
	private void drawNsharpSkewtDynamicData(IGraphicsTarget target, double zoomLevel,
            WGraphics world) throws VizException {
    	double dispX;
		double dispY;
		IExtent ext = getDescriptor().getRenderableDisplay().getExtent();
		dispX = ext.getMinX() + 20 * zoomLevel* xRatio;
		dispY = ext.getMinY() + 70 * zoomLevel* yRatio;
    	//Column 1: pressure, C and F
    	target.drawString(font10, sPressure, dispX, dispY, 0.0,
                TextStyle.NORMAL, NsharpConstants.color_white, HorizontalAlignment.LEFT,
                VerticalAlignment.BOTTOM, null);

    	target.drawString(font10, sTemperatureC, dispX, dispY+15* zoomLevel* yRatio, 0.0,
    			TextStyle.NORMAL, NsharpConstants.color_red, HorizontalAlignment.LEFT,
    			VerticalAlignment.BOTTOM, null);
    	target.drawString(font10, sTemperatureF, dispX, dispY+30* zoomLevel* yRatio, 0.0,
    			TextStyle.NORMAL, NsharpConstants.color_red, HorizontalAlignment.LEFT,
    			VerticalAlignment.BOTTOM, null);
    	//column 2: m, ft, mixing ratio
    	float heightM = nsharpNative.nsharpLib.ihght((float)dPressure);
    	String sHeightM = String.format("%.0fm",heightM);
    	target.drawString(font10, sHeightM, dispX+60* zoomLevel* xRatio, dispY, 0.0,
    			TextStyle.NORMAL, NsharpConstants.color_cyan, HorizontalAlignment.LEFT,
    			VerticalAlignment.BOTTOM, null);
    	String sHeightFt = String.format("%.0fft",NsharpConstants.metersToFeet.convert(heightM));
    	target.drawString(font10, sHeightFt, dispX+60* zoomLevel* xRatio, dispY+15* zoomLevel* yRatio, 0.0,
    			TextStyle.NORMAL, NsharpConstants.color_cyan, HorizontalAlignment.LEFT,
    			VerticalAlignment.BOTTOM, null);
    	target.drawString(font10, sMixingRatio, dispX+60* zoomLevel* xRatio, dispY+30* zoomLevel* yRatio, 0.0,
    			TextStyle.NORMAL, NsharpConstants.color_green, HorizontalAlignment.LEFT,
    			VerticalAlignment.BOTTOM, null);
    	//column 3: Theta, ThetaW, ThetaE
    	target.drawString(font10, sThetaInK, dispX+120* zoomLevel* xRatio, dispY, 0.0,
                TextStyle.NORMAL, NsharpConstants.color_yellow, HorizontalAlignment.LEFT,
                VerticalAlignment.BOTTOM, null);
    	target.drawString(font10, sWThetaInK, dispX+120* zoomLevel* xRatio, dispY+15* zoomLevel* yRatio, 0.0,
                TextStyle.NORMAL, NsharpConstants.color_yellow, HorizontalAlignment.LEFT,
                VerticalAlignment.BOTTOM, null);
    	target.drawString(font10, sEThetaInK, dispX+120* zoomLevel* xRatio, dispY+30* zoomLevel* yRatio, 0.0,
                TextStyle.NORMAL, NsharpConstants.color_yellow, HorizontalAlignment.LEFT,
                VerticalAlignment.BOTTOM, null);
        
    }
    private void paintIcing(double zoomLevel,IGraphicsTarget target) throws VizException{
    	WGraphics plotWorld = icingBackground.getWorld();
    	target.setupClippingPlane(icingBackground.getPe());
    	try {

    		if((graphConfigProperty!=null && graphConfigProperty.isWindBarb() == true) || graphConfigProperty== null) {
    			plotWorld.setWorldCoordinates(NsharpConstants.ICING_RELATIVE_HUMIDITY_LEFT, icingBackground.toLogScale(NsharpConstants.ICING_PRESSURE_LEVEL_BOTTOM),        		
    					NsharpConstants.ICING_RELATIVE_HUMIDITY_RIGHT, icingBackground.toLogScale(NsharpConstants.ICING_PRESSURE_LEVEL_TOP));
    			NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_WIND_BARB]);
    			double xPos = icingBackground.getWindBarbXPosition();//90;//
    			//System.out.println("ice wind x pos="+xPos);
    			drawNsharpWindBarb(target, zoomLevel, plotWorld,lp.getLineColor(), this.soundingLys,xPos, NsharpConstants.ICING_PRESSURE_LEVEL_TOP);
    		}
    	} catch (VizException e) {
    		// TODO Auto-generated catch block
    		e.printStackTrace();
    	}
    	//Chin NOTE: icining wireframeshapes are created dynamically ONLY when icing display is to be shown
    	//However, Skewt wireframeshapes are created when new sounding is loaded.
    	if(icingRHShape==null){
    		// current WorldCoordinates for RH already loaded
    		plotWorld.setWorldCoordinates(NsharpConstants.ICING_RELATIVE_HUMIDITY_LEFT, icingBackground.toLogScale(NsharpConstants.ICING_PRESSURE_LEVEL_TOP),        		
    				NsharpConstants.ICING_RELATIVE_HUMIDITY_RIGHT, icingBackground.toLogScale(NsharpConstants.ICING_PRESSURE_LEVEL_BOTTOM));

    		createIcingRHShape(plotWorld);
    	}
    	if(icingRHShape != null){
    		NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_ICING_RH]);			
    		target.drawWireframeShape(icingRHShape,lp.getLineColor(), lp.getLineWidth(),lp.getLineStyle(),font10);
    	}
    	if(icingTempShape==null){
    		plotWorld.setWorldCoordinates(NsharpConstants.ICING_TEMPERATURE_LEFT, icingBackground.toLogScale(NsharpConstants.ICING_PRESSURE_LEVEL_TOP),        		
    				NsharpConstants.ICING_TEMPERATURE_RIGHT, icingBackground.toLogScale(NsharpConstants.ICING_PRESSURE_LEVEL_BOTTOM));
    		createIcingTempShape(plotWorld);
    	}
    	if(icingTempShape != null){
    		NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_ICING_TEMP]);			
    		target.drawWireframeShape(icingTempShape,lp.getLineColor(), lp.getLineWidth(),lp.getLineStyle(),font10);
    	}
    	if(icingEPIShape==null){
    		plotWorld.setWorldCoordinates(NsharpConstants.ICING_TEMPERATURE_LEFT, icingBackground.toLogScale(NsharpConstants.ICING_PRESSURE_LEVEL_TOP),        		
    				NsharpConstants.ICING_TEMPERATURE_RIGHT, icingBackground.toLogScale(NsharpConstants.ICING_PRESSURE_LEVEL_BOTTOM));
    		createIcingEPIShape(plotWorld);
    	}
    	if(icingEPIShape != null){
    		NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_ICING_EPI]);			
    		target.drawWireframeShape(icingEPIShape,lp.getLineColor(), lp.getLineWidth(),lp.getLineStyle(),font10);
    	}

    	target.clearClippingPlane();
    	

    }
    private void paintTurbulence(double zoomLevel,IGraphicsTarget target) throws VizException{
    	WGraphics plotWorld = turbBackground.getWorld();
    	target.setupClippingPlane(turbBackground.getPe());
    	//Chin NOTE: turbulence wireframeshapes are created dynamically ONLY when turbulence display is to be shown
    	//However, Skewt wireframeshapes are created when new sounding is loaded.
    	try {
    		//Chin:NOTE: LN Richardson number is plotted with positive number increase to left and netagive number decrease to its right side.
    		// Therefore, we have to set its world X coordintion in a reverse way as plotting Icing wind barb.
    		if((graphConfigProperty!=null && graphConfigProperty.isWindBarb() == true) || graphConfigProperty== null) {
    			plotWorld.setWorldCoordinates(NsharpConstants.TURBULENCE_LN_RICHARDSON_NUMBER_RIGHT, turbBackground.toLogScale(NsharpConstants.TURBULENCE_PRESSURE_LEVEL_BOTTOM),        		
    					NsharpConstants.TURBULENCE_LN_RICHARDSON_NUMBER_LEFT, turbBackground.toLogScale(NsharpConstants.TURBULENCE_PRESSURE_LEVEL_TOP));
    			NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_WIND_BARB]);
    			double xPos = turbBackground.getWindBarbXPosition();
    			//System.out.println("turb wind x pos="+xPos);
    			drawNsharpWindBarb(target, zoomLevel, plotWorld, lp.getLineColor(), this.soundingLys, xPos/*7*/, NsharpConstants.TURBULENCE_PRESSURE_LEVEL_TOP);
    		} 
    	}catch (VizException e) {
    		// TODO Auto-generated catch block
    		e.printStackTrace();
    	}
    	if(turbLnShape==null || turbWindShearShape==null){
    		createTurbulenceShapes(plotWorld);
    	}
    	if(turbLnShape != null){
    		NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_TURBULENCE_LN]);	
    		target.drawWireframeShape(turbLnShape, lp.getLineColor(), lp.getLineWidth(),lp.getLineStyle(),font10);

    	}
    	if(turbWindShearShape != null){
    		NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_TURBULENCE_WS]);	
    		target.drawWireframeShape(turbWindShearShape, lp.getLineColor(), lp.getLineWidth(),lp.getLineStyle(),font10);
    	}
    	
    	target.clearClippingPlane(); 

    }
    @SuppressWarnings("deprecation")
	private void drawNsharpDataFilelabel(IGraphicsTarget target, double zoomLevel)
    throws VizException {
    	double dispX, xmin;
		double dispY, ymin;
		IExtent ext = getDescriptor().getRenderableDisplay().getExtent();
		xmin = ext.getMinX();  //Extent's viewable envelope min x and y
		ymin = ext.getMinY();
		dispX = xmin + 20 * zoomLevel*  xRatio;
		dispY = ymin + 35 * zoomLevel* yRatio;
		//System.out.println("zoomLevel="+zoomLevel+" xmin="+xmin+" dispX="+dispX);
    	RGB pickedStnColor = NsharpConstants.color_green;   	
    	String pickedStnInfoStr="";
    	String latlonStr="";
    	if(rscHandler.isOverlayIsOn()){
    		NsharpSoundingElementStateProperty preSndProfileProp= rscHandler.getPreSndProfileProp(); 
    		if(preSndProfileProp!= null){
    			pickedStnColor = linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_OVERLAY2]).getLineColor();
    			String stnInfoStr = preSndProfileProp.elementDescription;
    			latlonStr = Math.rint(preSndProfileProp.stnInfo.getLatitude()*100)/100 + "," + Math.rint(preSndProfileProp.stnInfo.getLongitude()*100)/100;
    			target.drawString(font10, stnInfoStr+" "+latlonStr, dispX + 300 * zoomLevel*  xRatio, dispY, 0.0,
    					TextStyle.NORMAL, pickedStnColor, HorizontalAlignment.LEFT,
    					VerticalAlignment.MIDDLE, null);
    		}
    		pickedStnColor = linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_OVERLAY1]).getLineColor();
    	}
    	//dispX = skewtXOrig+20;
    	pickedStnInfoStr = rscHandler.getPickedStnInfoStr();
    	//Also draw stn lat/lon info string and sounding type string
    	NsharpStationInfo pickedStnInfo = rscHandler.getPickedStnInfo();
    	if(pickedStnInfo != null){
    		latlonStr = Math.rint(pickedStnInfo.getLatitude()*100)/100 + "," + Math.rint(pickedStnInfo.getLongitude()*100)/100;
    	}
    	target.drawString(font10, pickedStnInfoStr+" "+latlonStr, dispX, dispY, 0.0,
				TextStyle.NORMAL, pickedStnColor, HorizontalAlignment.LEFT,
				VerticalAlignment.MIDDLE, null);

    }

	@SuppressWarnings("deprecation")
	@Override
	protected void paintInternal(IGraphicsTarget target,
			PaintProperties paintProps) throws VizException {
		//System.out.println("NsharpSkewTPaneResource paintInternal called! I am pane #"+ descriptor.getPaneNumber());
		//double X = NsharpConstants.WIND_BX_X_ORIG;
		//double Y = 80;
		super.paintInternal(target, paintProps);
		//System.out.println("skew paintInternal zoomL="+currentZoomLevel);
		if(rscHandler== null)
			return;
		/*if(mycurrentZoomLevel != currentZoomLevel){
			mycurrentZoomLevel = currentZoomLevel;
			if(heightMarkRscShape!=null)
				heightMarkRscShape.dispose();
			createRscHeightMarkShape();
			rscHandler.getWitoPaneRsc().handleZooming();
		}*/
		/* Chin : turn it off for now
		skewTBackground.setCurrentFont(currentFont10Size);
		icingBackground.setCurrentFont(currentFont10Size);
		skewTBackground.magnifyFont(currentZoomLevel);
		icingBackground.magnifyFont(currentZoomLevel);*/
		
		if(currentGraphMode== NsharpConstants.GRAPH_SKEWT)
			skewTBackground.paint(target, paintProps);
		else if(currentGraphMode == NsharpConstants.GRAPH_ICING)
			icingBackground.paint(target, paintProps);
		else if(currentGraphMode == NsharpConstants.GRAPH_TURB)
			turbBackground.paint(target, paintProps);
		else
			//default
			skewTBackground.paint(target, paintProps);
		
		if(soundingLys!= null){
			this.font10.setSmoothing(false);
			this.font10.setScaleFont(false);
			this.font9.setSmoothing(false);
			this.font9.setScaleFont(false);
			this.font12.setSmoothing(false);
			this.font12.setScaleFont(false);
			//nsharpNative.populateSndgData(soundingLys);
			if(currentGraphMode== NsharpConstants.GRAPH_SKEWT){
				target.setupClippingPlane(pe);
				//plot temp curve, when constructing pressureTempRscShapeList, it already considered 
				// comparison, overlay, etc..so, just draw it.
				for(NsharpShapeAndLineProperty shapeNColor: pressureTempRscShapeList){
					target.drawWireframeShape(shapeNColor.getShape(), shapeNColor.getLp().getLineColor(), shapeNColor.getLp().getLineWidth(), shapeNColor.getLp().getLineStyle(),font10);//commonLinewidth*2,commonLineStyle,font10);
				}
				boolean compareStnIsOn = rscHandler.isCompareStnIsOn();
				boolean compareTmIsOn = rscHandler.isCompareTmIsOn();
				boolean editGraphOn= rscHandler.isEditGraphOn();
				boolean overlayIsOn = rscHandler.isOverlayIsOn();
				if(graphConfigProperty != null ){        		        		
					if(graphConfigProperty.isTemp() == true && !compareStnIsOn && !compareTmIsOn){
						if(editGraphOn)
							plotPressureTempEditPoints(target, world, NsharpConstants.color_red, TEMP_TYPE, this.soundingLys);
					}
					// dew point curve
					if(graphConfigProperty.isDewp() == true && !compareStnIsOn && !compareTmIsOn){
						if(editGraphOn)
							plotPressureTempEditPoints(target, world, NsharpConstants.color_green, DEWPOINT_TYPE, this.soundingLys);
					}
					//plot wetbulb trace
					if(graphConfigProperty.isWetBulb() == true && !compareStnIsOn && !compareTmIsOn){
						NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_WETBULB]);
						target.drawWireframeShape(wetBulbTraceRscShape, lp.getLineColor(),lp.getLineWidth(),lp.getLineStyle(),font10);//NsharpConstants.color_cyan, commonLinewidth,commonLineStyle,font10);
					}
					//plot virtual temp trace
					if(graphConfigProperty.isVTemp() == true && !compareStnIsOn && !compareTmIsOn){		
						NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_VIRTUAL_TEMP]);
						target.drawWireframeShape(vtempTraceCurveRscShape,lp.getLineColor(),lp.getLineWidth(),lp.getLineStyle(),font10);//NsharpConstants.color_red, commonLinewidth*2, LineStyle.DASHED,font10);
					}
					// parcel trace curve
					if(graphConfigProperty.isParcel() == true && !compareStnIsOn && !compareTmIsOn){
						if(soundingLys.size() > 0){
							for (IWireframeShape shape: parcelTraceRscShapeList){
								NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_PARCEL]);
								target.drawWireframeShape(shape, lp.getLineColor(),lp.getLineWidth(),lp.getLineStyle(),font10);//NsharpConstants.color_white, commonLinewidth,LineStyle.DASHED,font10);
							}
						}
					}
					if(graphConfigProperty.isEffLayer() == true && !compareStnIsOn && !compareTmIsOn)
						//draw effective layer lines
						drawEffectiveLayerLines(target);

					//cloud
					if(graphConfigProperty.isCloud() == true && !compareStnIsOn && !compareTmIsOn){
						if(cloudFMShape!= null)
							target.drawShadedShape(cloudFMShape, 1f);
						if(cloudFMLabelShape!= null)
							target.drawWireframeShape(cloudFMLabelShape, NsharpConstants.color_chocolate, commonLinewidth*3,
									commonLineStyle,font9);
						if(cloudCEShape!= null)
							target.drawShadedShape(cloudCEShape, 1f);
					}
				}
				else{
					//by default, draw everything
					if(!compareStnIsOn && !compareTmIsOn){
						if(editGraphOn)
							plotPressureTempEditPoints(target, world, NsharpConstants.color_red, TEMP_TYPE, this.soundingLys);
						// dew point curve
						if(editGraphOn)
							plotPressureTempEditPoints(target, world, NsharpConstants.color_green, DEWPOINT_TYPE, this.soundingLys);
						//plot wetbulb trace
						NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_WETBULB]);
						target.drawWireframeShape(wetBulbTraceRscShape, lp.getLineColor(),lp.getLineWidth(),lp.getLineStyle(),font10);//NsharpConstants.color_cyan, commonLinewidth,commonLineStyle,font10);
						//plot virtual temp trace
						lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_VIRTUAL_TEMP]);
						target.drawWireframeShape(vtempTraceCurveRscShape,lp.getLineColor(),lp.getLineWidth(),lp.getLineStyle(),font10);//NsharpConstants.color_red, commonLinewidth*2, LineStyle.DASHED,font10);

						// parcel trace curve
						if(soundingLys.size() > 0){
							for (IWireframeShape shape: parcelTraceRscShapeList){
								lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_PARCEL]);
								target.drawWireframeShape(shape, lp.getLineColor(),lp.getLineWidth(),lp.getLineStyle(),font10);//NsharpConstants.color_white, commonLinewidth,LineStyle.DASHED,font10);
							}
						}
						//draw effective layer lines
						drawEffectiveLayerLines(target);
					}
				}
				if(plotInteractiveTemp == true ){
					plotNsharpInteractiveTemp( target,  currentZoomLevel,
							world,  NsharpConstants.color_white);
				}
				target.clearClippingPlane();


				// Wind Barb
				if((graphConfigProperty!=null && graphConfigProperty.isWindBarb() == true) || graphConfigProperty== null) {
					double xPos = skewTBackground.getWindBarbXPosition();
					if(overlayIsOn == true && this.previousSoundingLys!=null){
						drawNsharpWindBarb(target, currentZoomLevel, world, linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_OVERLAY1]).getLineColor(), this.soundingLys, xPos,100);
						if(!previousSoundingLys.equals(soundingLys))
							drawNsharpWindBarb(target, currentZoomLevel, world,  linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_OVERLAY2]).getLineColor(), this.previousSoundingLys, xPos - NsharpResourceHandler.BARB_LENGTH,100);
					}
					else{
						if(!compareStnIsOn  && !compareTmIsOn){
							NsharpLineProperty lp =linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_WIND_BARB]);
							drawNsharpWindBarb(target, currentZoomLevel, world, lp.getLineColor()/*NsharpConstants.color_yellow*/, this.soundingLys, xPos,100);
						}
					}
					//System.out.println("x1 pos"+xPos+ " x2 pos="+  (xPos - NsharpResourceHandler.BARB_LENGTH));
				}
				
				target.drawWireframeShape(heightMarkRscShape, NsharpConstants.color_red, 1, LineStyle.SOLID, font10);

				//if(!compareStnIsOn){
				//draw EL, LFC, LCL, FZL, -20C, -30C lines
				drawLclLine(target);

				// draw cursor data
				if(cursorInSkewT== true){
					if(curseToggledFontLevel < CURSER_STRING_OFF)
						drawNsharpSkewtCursorData(target);
					//draw dynamic temp, theta, height     	    		
					drawNsharpSkewtDynamicData(target, currentZoomLevel, world);

				}
				//}

			}// end of currentGraphMode= NsharpConstants.GRAPH_SKEWT
			else if(currentGraphMode == NsharpConstants.GRAPH_ICING){
				paintIcing( currentZoomLevel, target);
			}
			else if(currentGraphMode == NsharpConstants.GRAPH_TURB){
				paintTurbulence( currentZoomLevel, target);
			}
    		drawNsharpDataFilelabel(target, currentZoomLevel);
		}
	}

	@Override
	protected void initInternal(IGraphicsTarget target) throws VizException {
		super.initInternal(target);
		currentCanvasBoundWidth = NsharpConstants.SKEWT_PANE_REC_WIDTH;
		currentCanvasBoundHeight = NsharpConstants.SKEWT_PANE_REC_HEIGHT;
		myDefaultCanvasWidth = NsharpConstants.SKEWT_PANE_REC_WIDTH;
		myDefaultCanvasHeight = NsharpConstants.SKEWT_PANE_REC_HEIGHT;	
		//System.out.print("NsharpSkewTPaneResource ::: initInternal entered!!!!!\n");
		this.rectangle = new Rectangle(skewtXOrig, skewtYOrig,
				skewtWidth, skewtHeight);
		pe = new PixelExtent(this.rectangle);
		world = new WGraphics(this.rectangle);

		world.setWorldCoordinates(NsharpConstants.left, NsharpConstants.top,
				NsharpConstants.right, NsharpConstants.bottom);
		skewTBackground.initInternal(target);
		icingBackground.initInternal(target);
		turbBackground.initInternal(target);
		createRscWireFrameShapes();
	}
	
	public String updateDynamicData(Coordinate c) throws VizException {
		this.cursorCor = c;
		try {
			//System.out.println(" updateDynamicData entered!!!!!C.x="+c.x + " c.y="+c.y);

			if (skewTBackground.contains(c)) {
				c = NsharpWxMath.reverseSkewTXY(skewTBackground.getWorld()
						.unMap(c.x, c.y));
				double p_mb = c.y;
				double t_C = c.x; // Celsius
				double t_F = celciusToFahrenheit.convert(c.x);
				double theta = celciusToKelvin.convert(WxMath.theta(p_mb, t_C,
						1000));
				double wtheta = celciusToKelvin.convert(WxMath.thetaw(p_mb,
						t_C, t_C));
				double etheta = celciusToKelvin.convert(WxMath.thetae(p_mb,
						t_C, t_C));
				double mixRatio = WxMath.mixingRatio(p_mb, t_C);
				dPressure = p_mb;

				sPressure = String.format(
						"%.0f mb",p_mb, NsharpConstants.THETA_SYMBOL);
				sTemperatureC = String.format("%.1f%cC",
						t_C, NsharpConstants.DEGREE_SYMBOL);
				sTemperatureF = String.format("%.1f%cF",
						t_F,NsharpConstants.DEGREE_SYMBOL);

				sThetaInK = String.format("%c=%.0fK",
						NsharpConstants.THETA_SYMBOL,theta);
				sWThetaInK = String.format("%cw=%.0fK",
						NsharpConstants.THETA_SYMBOL,wtheta);
				sEThetaInK = String.format("%ce=%.0fK",
						NsharpConstants.THETA_SYMBOL,etheta);
				sMixingRatio = String.format("%.0fg/Kg",mixRatio);
			}
		} catch (Exception e) {
			UFStatus.getHandler().handle(Priority.PROBLEM, "Exception translating coordinate", e);
		}
		return "";
	}
	private void createRscParcelTraceShape( short parcelType, float userPre){
		//System.out.println("createRscParcelTraceShape called defoine_parcel pType="+parcelType+" pre="+ userPre);
		IWireframeShape shape = target.createWireframeShape(false,descriptor );
		shape.allocate(40);
		//call native define_parcel() with parcel type and user defined pressure (if user defined it)
		nsharpNative.nsharpLib.define_parcel(parcelType,userPre);

		_lplvalues lpvls = new _lplvalues();
		nsharpNative.nsharpLib.get_lpvaluesData(lpvls);

		float sfctemp, sfcdwpt, sfcpres;
		sfctemp = lpvls.temp;
		sfcdwpt = lpvls.dwpt;
		sfcpres = lpvls.pres;

		float vtemp = nsharpNative.nsharpLib.virtemp (sfcpres, sfctemp, sfcdwpt);
		Coordinate c1 = NsharpWxMath.getSkewTXY(sfcpres, vtemp);
		c1.x = world.mapX(c1.x);
		c1.y = world.mapY(c1.y);
		FloatByReference p2 = new FloatByReference(0), t2 = new FloatByReference(0);;
		nsharpNative.nsharpLib.drylift (sfcpres, sfctemp, sfcdwpt, p2, t2);
		vtemp = nsharpNative.nsharpLib.virtemp (p2.getValue(), t2.getValue(), t2.getValue());
		Coordinate c2 = NsharpWxMath.getSkewTXY(p2.getValue(), vtemp);
		c2.x = world.mapX(c2.x);
		c2.y = world.mapY(c2.y);

		double [][] lines = {{c1.x, c1.y},{c2.x, c2.y}};
		shape.addLineSegment(lines);

		c1 = c2;


		float t3;
		for (float i = p2.getValue() - 50; i >= 100; i = i - 50)
		{
			t3 = nsharpNative.nsharpLib.wetlift (p2.getValue(), t2.getValue(), i);
			vtemp = nsharpNative.nsharpLib.virtemp (i, t3, t3);
			c2 = NsharpWxMath.getSkewTXY(i, vtemp);
			c2.x = world.mapX(c2.x);
			c2.y = world.mapY(c2.y);

			double [][] lines1 = {{c1.x, c1.y},{c2.x, c2.y}};
			shape.addLineSegment(lines1);

			c1 = c2;
		}

		t3 = nsharpNative.nsharpLib.wetlift (p2.getValue(), t2.getValue(), 100);
		vtemp = nsharpNative.nsharpLib.virtemp (100, t3, t3);
		c2 = NsharpWxMath.getSkewTXY(100, vtemp);
		c2.x = world.mapX(c2.x);
		c2.y = world.mapY(c2.y);

		double [][] lines2 = {{c1.x, c1.y},{c2.x, c2.y}};
		shape.addLineSegment(lines2);

		shape.compile();

		parcelTraceRscShapeList.add(shape);

	}
	public void createParcelShapes(List<ParcelData> parcelList) {

		if(parcelTraceRscShapeList.size()>0){
			for(IWireframeShape shape: parcelTraceRscShapeList){
				shape.dispose();
			}
			parcelTraceRscShapeList.clear();
		}


		for (ParcelData parData: parcelList){
			createRscParcelTraceShape( parData.parcelType,parData.parcelLayerPressure);
		}
	}
	private void createRscHeightMarkShape(){
		
		heightMarkRscShape = target.createWireframeShape(false,descriptor );
		heightMarkRscShape.allocate(20);
		//plot meter  scales...
		IExtent ext = descriptor.getRenderableDisplay().getExtent();
        double xmin = ext.getMinX();  //Extent's viewable envelope min x and y
        double xDefault = world.mapX(NsharpConstants.left);
        if(xmin <xDefault)
        	xmin = xDefault;
        double dispX1 = xmin + 30 * currentZoomLevel * xRatio;
        double dispX2 = xmin + 60 * currentZoomLevel * xRatio;
		for (int j = 0; j < NsharpConstants.HEIGHT_LEVEL_METERS.length; j++) {
			int meters = NsharpConstants.HEIGHT_LEVEL_METERS[j];
			// plot the meters scale
			double pressure = nsharpNative.nsharpLib.ipres(meters+(int)(soundingLys.get(0).getGeoHeight()));
			double y = world.mapY(NsharpWxMath.getSkewTXY(pressure, -50).y);
			//System.out.println("world.mapX(NsharpConstants.left) + 20 =" + (world.mapX(NsharpConstants.left) + 20));
			double [][] lines = {{dispX1, y},{dispX2, y}};
			heightMarkRscShape.addLineSegment(lines);
			double [] lblXy = {dispX2,y-5};
			heightMarkRscShape.addLabel(Integer.toString(meters/1000)+" km", lblXy);
		} 
		// plot surface level mark{
		if(soundingLys.get(0).getGeoHeight() != NsharpNativeConstants.NSHARP_NATIVE_INVALID_DATA)
		{
			double y = world.mapY(NsharpWxMath.getSkewTXY(soundingLys.get(0).getPressure(), -50).y);
			double [][] lines = {{dispX1, y},{dispX2, y}};
			heightMarkRscShape.addLineSegment(lines);
			double [] lblXy = {dispX2,y-5};
			heightMarkRscShape.addLabel("SFC("+Integer.toString((int)(soundingLys.get(0).getGeoHeight()))+"m)", lblXy);
		}
		heightMarkRscShape.compile();
	}
	public void createRscwetBulbTraceShape(){
		if(wetBulbTraceRscShape!=null){
			wetBulbTraceRscShape.dispose();
			wetBulbTraceRscShape=null;
		}
		wetBulbTraceRscShape = target.createWireframeShape(false,descriptor );
		wetBulbTraceRscShape.allocate(soundingLys.size() * 2);
		float t1;

		Coordinate c2 =  null;
		Coordinate c1;
		// draw trace
		
		for (NcSoundingLayer layer : this.soundingLys) {
			if (layer.getDewpoint() > -200 && layer.getPressure() >= 100){
				t1 = nsharpNative.nsharpLib.wetbulb(layer.getPressure(), layer.getTemperature(),
						layer.getDewpoint());

				c1 = NsharpWxMath.getSkewTXY(layer.getPressure(), t1);
				c1.x = world.mapX(c1.x);
				c1.y = world.mapY(c1.y);
				if(c2!= null){

					double [][] lines = {{c1.x, c1.y},{c2.x, c2.y}};
					wetBulbTraceRscShape.addLineSegment(lines);

				}
				c2 =  c1;
			}
		}
		wetBulbTraceRscShape.compile();
	}
	private void createTurbulenceShapes(WGraphics world){		
		if(turbLnShape!=null)
			turbLnShape.dispose();
		turbLnShape = target.createWireframeShape(false,descriptor );
		
		turbLnShape.allocate(this.soundingLys.size() * 2);
		turbWindShearShape  = target.createWireframeShape(false,descriptor );
		turbWindShearShape.allocate(this.soundingLys.size() * 2);
		Coordinate pointALn = null;
		Coordinate pointBLn=null;
		Coordinate pointAWsh = null;
		Coordinate pointBWsh=null;
		double g= 9.8f, Ri;
		double t0,t1,v0,v1, u0,u1, windshear0, windshearsqrd,tke_windshear_prod;
		double pressure0=0, pressure1,midpressure0, p, high0=0,high1;
		double theta1=0, theta0=0,dthetadz0,meanTheta;
		boolean first=true;
		NcSoundingLayer layer0, layer1;
		for (int i=0; i< soundingLys.size()-1; i++) {
			layer0 = soundingLys.get(i);
			pressure0= layer0.getPressure();
			t0= layer0.getTemperature();
			high0= layer0.getGeoHeight();
			layer1 = soundingLys.get(i+1);
			t1= layer1.getTemperature();
			high1= layer1.getGeoHeight();
			if( t0<= NsharpNativeConstants.NSHARP_NATIVE_INVALID_DATA || t1<= NsharpNativeConstants.NSHARP_NATIVE_INVALID_DATA||
				pressure0 <= NsharpConstants.TURBULENCE_PRESSURE_LEVEL_TOP )
				continue;
			pressure1= layer1.getPressure();
			v0=nsharpNative.nsharpLib.iwndv((float)pressure0);
			v1=nsharpNative.nsharpLib.iwndv((float)pressure1);
			u0=nsharpNative.nsharpLib.iwndu((float)pressure0);
			u1=nsharpNative.nsharpLib.iwndu((float)pressure1);
			windshear0=Math.sqrt((u1-u0)*(u1-u0)+(v1-v0)*(v1-v0))*.51479/(high1-high0);
			midpressure0 = (pressure1+pressure0)/2;
			theta0=WxMath.theta(pressure0,t0, 1000)+273.15;
			theta1=WxMath.theta(pressure1,t1, 1000)+273.15;
			meanTheta=(theta1+theta0)/2.0f;
			dthetadz0=(theta1-theta0)/(high1-high0);
			if (windshear0 != 0.0 ) {
				windshearsqrd=(windshear0*windshear0);
				Ri=(g/meanTheta)*(dthetadz0/windshearsqrd);
				world.setWorldCoordinates(NsharpConstants.TURBULENCE_LN_RICHARDSON_NUMBER_LEFT, turbBackground.toLogScale(NsharpConstants.TURBULENCE_PRESSURE_LEVEL_TOP),        		
						NsharpConstants.TURBULENCE_LN_RICHARDSON_NUMBER_RIGHT, turbBackground.toLogScale(NsharpConstants.TURBULENCE_PRESSURE_LEVEL_BOTTOM));
				//System.out.println("world viewYmin="+world.getViewYmin()+" viewYmax="+world.getViewYmax()+" wolrdYmin="+ world.getWorldYmin()+" wolrdYmax="+ world.getWorldYmax()
		        //		+" viewXmin="+world.getViewXmin()+" viewXmax="+world.getViewXmax()+" wolrdXmin="+ world.getWorldXmin()+" wolrdXmax="+ world.getWorldXmax());
				
				pointALn = new Coordinate();
				p = turbBackground.toLogScale(midpressure0);
				pointALn.x = world.mapX(Math.log(Ri));
				pointALn.y = world.mapY(p);
				world.setWorldCoordinates(NsharpConstants.TURBULENCE_WIND_SHEAR_TKE_LEFT, turbBackground.toLogScale(NsharpConstants.TURBULENCE_PRESSURE_LEVEL_TOP),        		
						NsharpConstants.TURBULENCE_WIND_SHEAR_TKE_RIGHT, turbBackground.toLogScale(NsharpConstants.TURBULENCE_PRESSURE_LEVEL_BOTTOM));
				pointAWsh = new Coordinate();
				tke_windshear_prod=0.54*(high1-high0)*windshearsqrd;
				pointAWsh.x = world.mapX( tke_windshear_prod*100);
				pointAWsh.y = world.mapY(p);
				//System.out.println("P0="+pressure0+" dthetadz0="+dthetadz0+" theta0="+theta0+" log(Ri)="+Math.log(Ri)+ " pointAx="+pointALn.x+ " y="+pointALn.y);
				if (! first) {
					double [][] linesLn = {{pointALn.x, pointALn.y},{pointBLn.x, pointBLn.y}};
					double [][] linesWsh = {{pointAWsh.x, pointAWsh.y},{pointBWsh.x, pointBWsh.y}};
					turbLnShape.addLineSegment(linesLn);
					turbWindShearShape.addLineSegment(linesWsh);
					
		          }
		          else{
		        	  first=false;
		          }
		          pointBLn = pointALn;
		          pointBWsh = pointAWsh;
			}
		}
        
        turbLnShape.compile();
        turbWindShearShape.compile();
	}
	
	/*
	 * Chin:: NOTE:::
	 * This plotting function is based on the algorithm of draw_ICG() at xwvid1.c of AWC Nsharp source code
	 * by LARRY J. HINSON AWC/KCMO    
	 * 
	 */    
	private void createIcingRHShape(WGraphics world){		
		//System.out.println("world viewYmin="+world.getViewYmin()+" viewYmax="+world.getViewYmax()+" wolrdYmin="+ world.getWorldYmin()+" wolrdYmax="+ world.getWorldYmax()
		//        		+" viewXmin="+world.getViewXmin()+" viewXmax="+world.getViewXmax()+" wolrdXmin="+ world.getWorldXmin()+" wolrdXmax="+ world.getWorldXmax());
		
		
		icingRHShape = target.createWireframeShape(false,descriptor );
		icingRHShape.allocate(this.soundingLys.size() * 2);
		Coordinate c0 = null;
		
        for (NcSoundingLayer layer : soundingLys) {
        	double pressure = layer.getPressure();
            if (pressure >= NsharpConstants.ICING_PRESSURE_LEVEL_TOP
                    && pressure <= NsharpConstants.ICING_PRESSURE_LEVEL_BOTTOM) {

            	FloatByReference parm= new FloatByReference(0);
				float relh= nsharpNative.nsharpLib.relh((float)pressure, parm);
				Coordinate c1 = new Coordinate();
                double p = icingBackground.toLogScale(pressure);
                c1.x = world.mapX(relh);
                c1.y = world.mapY(p);
                //System.out.println("RH="+relh+ " p="+pressure+ " x="+c1.x+ " y="+c1.y);
                if (c0 != null) {
                		double [][] lines = {{c0.x, c0.y},{c1.x, c1.y}};
                		icingRHShape.addLineSegment(lines);
                 }
                c0 = c1;
            }
        }
        
        icingRHShape.compile();
	}

	private void createIcingEPIShape(WGraphics world){		
		//System.out.println("world viewYmin="+world.getViewYmin()+" viewYmax="+world.getViewYmax()+" wolrdYmin="+ world.getWorldYmin()+" wolrdYmax="+ world.getWorldYmax()
		//        		+" viewXmin="+world.getViewXmin()+" viewXmax="+world.getViewXmax()+" wolrdXmin="+ world.getWorldXmin()+" wolrdXmax="+ world.getWorldXmax());
		
		
		icingEPIShape = target.createWireframeShape(false,descriptor );
		icingEPIShape.allocate(this.soundingLys.size() * 2);
		Coordinate pointA = null;
		Coordinate pointB=null;
		boolean firstround=true;
		double t0,t1;
		double pressure0=0, pressure1,midpressure0, p, high0=0,high1;
		double const1=2500000.0/1004.0;
		double theta1=0,thetase1, theta0=0,thetase0=0,mixratio0,mixratio1,dthetasedz0;
		NcSoundingLayer layer0, layer1;
		for (int i=0; i< soundingLys.size()-1; i++) {
			layer0 = soundingLys.get(i);
			layer1 = soundingLys.get(i+1);
			t0= layer0.getTemperature();     
			t1= layer1.getTemperature();     
			pressure0 = layer0.getPressure();
			pressure1 = layer1.getPressure();
			if( t0<= NsharpNativeConstants.NSHARP_NATIVE_INVALID_DATA || t1<= NsharpNativeConstants.NSHARP_NATIVE_INVALID_DATA||
					(pressure0 < NsharpConstants.ICING_PRESSURE_LEVEL_TOP && pressure1 < NsharpConstants.ICING_PRESSURE_LEVEL_TOP))
				continue;
			theta1=WxMath.theta(pressure1,t1, 1000)+273.15;
			mixratio1 = WxMath.mixingRatio(pressure1, t1);
			thetase1 = theta1*Math.exp(const1*mixratio1*.001/(t1+273.15));
			high1= layer1.getGeoHeight();
			theta0=WxMath.theta(pressure0,t0, 1000)+273.15;
			mixratio0 = WxMath.mixingRatio(pressure0, t0);
			thetase0 = theta0*Math.exp(const1*mixratio0*.001/(t0+273.15));
			high0= layer0.getGeoHeight();
			//Do D-Theta-se/dz
			dthetasedz0=(thetase1-thetase0)/(high1-high0)*1E3;
			midpressure0 = (pressure1+pressure0)/2;
			pointA = new Coordinate();
			p = icingBackground.toLogScale(midpressure0);
			pointA.x = world.mapX(dthetasedz0);
			pointA.y = world.mapY(p);
			if(!firstround){
				//System.out.println("Temp="+t0+ " p="+pressure0+ "pointAx="+pointA.x+ " y="+pointA.y+ " pointBx="+pointB.x+ " y="+pointB.y);
				double [][] lines = {{pointA.x, pointA.y},{pointB.x, pointB.y}};
				icingEPIShape.addLineSegment(lines);

			}
			else
			{//this is first round, we need two pints for a line segment. We only have first point now.
				firstround= false;
			}
			pointB = pointA;

		}        
		icingEPIShape.compile();
	}
	/*
	 * Chin:: NOTE:::
	 * This plotting function is based on the algorithm of draw_ICG() at xwvid1.c of AWC Nsharp source code
	 * by LARRY J. HINSON AWC/KCMO    
	 * 
	 */    
	private void createIcingTempShape(WGraphics world){		
		//System.out.println("world viewYmin="+world.getViewYmin()+" viewYmax="+world.getViewYmax()+" wolrdYmin="+ world.getWorldYmin()+" wolrdYmax="+ world.getWorldYmax()
		//        		+" viewXmin="+world.getViewXmin()+" viewXmax="+world.getViewXmax()+" wolrdXmin="+ world.getWorldXmin()+" wolrdXmax="+ world.getWorldXmax());
		
		
		icingTempShape = target.createWireframeShape(false,descriptor );
		icingTempShape.allocate(this.soundingLys.size() * 2);
		Coordinate c0 = null;

		for (NcSoundingLayer layer : soundingLys) {
			double t= layer.getTemperature();     
			//if( t > NsharpConstants.ICING_TEMPERATURE_RIGHT || t< NsharpConstants.ICING_TEMPERATURE_LEFT)
			//	continue;
			double pressure = layer.getPressure();
			if (pressure >= NsharpConstants.ICING_PRESSURE_LEVEL_TOP
					&& pressure <= NsharpConstants.ICING_PRESSURE_LEVEL_BOTTOM) {

				Coordinate c1 = new Coordinate();
				double p = icingBackground.toLogScale(pressure);
				c1.x = world.mapX(t);
				c1.y = world.mapY(p);
				//System.out.println("Temp="+t+ " p="+pressure+ " x="+c1.x+ " y="+c1.y);
				if (c0 != null) {
					double [][] lines = {{c0.x, c0.y},{c1.x, c1.y}};
					icingTempShape.addLineSegment(lines);
				}
				c0 = c1;
			}
		}

		icingTempShape.compile();
	}
	private void createRscPressTempCurveShape(WGraphics WGc, List<NcSoundingLayer> soundingLays, NsharpLineProperty lineP){
		IWireframeShape shapeT = target.createWireframeShape(false,descriptor );
		shapeT.allocate(soundingLays.size() * 2);
		IWireframeShape shapeD = target.createWireframeShape(false,descriptor );
		shapeD.allocate(soundingLays.size() * 2);
		NsharpShapeAndLineProperty shNcolorT = new NsharpShapeAndLineProperty();
		NsharpShapeAndLineProperty shNcolorD = new NsharpShapeAndLineProperty();
		double maxPressure = NsharpWxMath.reverseSkewTXY(new Coordinate(0, WGc
				.getWorldYmax())).y;
		double minPressure = NsharpWxMath.reverseSkewTXY(new Coordinate(0, WGc
				.getWorldYmin())).y;
		boolean drawTemp=true, drawDew=true;
		//NsharpParametersSelectionConfigDialog configD = NsharpParametersSelectionConfigDialog.getAccess();
		graphConfigProperty = rscHandler.getGraphConfigProperty();
		if(graphConfigProperty!=null){
			drawTemp = graphConfigProperty.isTemp();
			drawDew = graphConfigProperty.isDewp();
		}
		Coordinate c0 = null, c01=null;
		for (NcSoundingLayer layer : soundingLays) {
			double t, d;
			t = layer.getTemperature();
			d = layer.getDewpoint();

			double pressure = layer.getPressure();
			if (t != NsharpNativeConstants.NSHARP_NATIVE_INVALID_DATA  && pressure >= minPressure
					&& pressure <= maxPressure) {

				Coordinate c1 = NsharpWxMath.getSkewTXY(pressure, t);

				c1.x = WGc.mapX(c1.x);
				c1.y = WGc.mapY(c1.y);
				if (c0 != null) {
					double [][] lines = {{c0.x, c0.y},{c1.x, c1.y}};
					shapeT.addLineSegment(lines);
				}
				c0 = c1;
			}
			if (d > -999  && pressure >= minPressure
					&& pressure <= maxPressure) {

				Coordinate c11 = NsharpWxMath.getSkewTXY(pressure, d);

				c11.x = WGc.mapX(c11.x);
				c11.y = WGc.mapY(c11.y);
				if (c01 != null) {
					double [][] lines = {{c01.x, c01.y},{c11.x, c11.y}};
					shapeD.addLineSegment(lines);
				}
				c01 = c11;
			}
		}

		shapeT.compile();
		shapeD.compile();

		shNcolorT.setShape(shapeT);
		shNcolorD.setShape(shapeD);
		if(!rscHandler.isOverlayIsOn() && !rscHandler.isCompareStnIsOn() && !rscHandler.isCompareTmIsOn()){
			//use default color 
			
			if(linePropertyMap!=null){
				shNcolorT.setLp( linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_TEMP]));//chin new config NsharpConstants.color_red;
				shNcolorD.setLp( linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_DEWP]));//NsharpConstants.color_green;           
			}
		}
		else
		{
			shNcolorT.setLp( lineP);
			shNcolorD.setLp( lineP);
		}
		//check draw temp and dew here. It is easier to do this way, otherwise, we have to check it every wghere
		if(drawTemp)
			pressureTempRscShapeList.add(shNcolorT);
		else
			shNcolorT.getShape().dispose();
		if(drawDew)
			pressureTempRscShapeList.add(shNcolorD);
		else
			shNcolorD.getShape().dispose();
	}
	public void createRscPressTempCurveShapeAll(){
		if(pressureTempRscShapeList.size()>0){
			for(NsharpShapeAndLineProperty shapeColor: pressureTempRscShapeList){
				shapeColor.getShape().dispose();
			}
			pressureTempRscShapeList.clear();
		}
		
		int currentTimeLineStateListIndex = rscHandler.getCurrentTimeLineStateListIndex();
		int currentStnStateListIndex = rscHandler.getCurrentStnStateListIndex();
		List<NsharpStationStateProperty> stnStateList = rscHandler.getStnStateList();
		List<NsharpTimeLineStateProperty> timeLineStateList = rscHandler.getTimeLineStateList();
		List<List<NsharpSoundingElementStateProperty>> stnTimeTable = rscHandler.getStnTimeTable();
		HashMap<String, List<NcSoundingLayer>> dataTimelineSndLysListMap = rscHandler.getDataTimelineSndLysListMap();
		if(rscHandler.isCompareStnIsOn() && currentTimeLineStateListIndex >=0){
			int colorIndex =NsharpConstants.LINE_COMP1;
			for(NsharpStationStateProperty elm: stnStateList) {
				if(elm.getStnState() == NsharpConstants.State.ACTIVE && 
						stnTimeTable.get(stnStateList.indexOf(elm)).get(currentTimeLineStateListIndex).getElementState() == NsharpConstants.State.AVAIL){
					List<NcSoundingLayer> soundingLayeys = dataTimelineSndLysListMap.get(stnTimeTable.get(stnStateList.indexOf(elm)).get(currentTimeLineStateListIndex).getElementDescription());
					NsharpLineProperty lp = linePropertyMap.get(NsharpConstants.lineNameArray[colorIndex]);
					colorIndex++;
					if(colorIndex > NsharpConstants.LINE_COMP10)
						colorIndex =NsharpConstants.LINE_COMP1;
					createRscPressTempCurveShape(world, soundingLayeys, lp);
				}
			}
		}
		else if(rscHandler.isCompareTmIsOn() && currentStnStateListIndex >=0 ){
			int colorIndex =NsharpConstants.LINE_COMP1;
			for(NsharpTimeLineStateProperty elm: timeLineStateList) {
				if(elm.getTimeState() == NsharpConstants.State.ACTIVE && 
						stnTimeTable.get(currentStnStateListIndex).get(timeLineStateList.indexOf(elm)).getElementState() == NsharpConstants.State.AVAIL){
					List<NcSoundingLayer> soundingLayeys = dataTimelineSndLysListMap.get(stnTimeTable.get(currentStnStateListIndex).get(timeLineStateList.indexOf(elm)).getElementDescription());
					NsharpLineProperty lp = linePropertyMap.get(NsharpConstants.lineNameArray[colorIndex]);
					colorIndex++;
					if(colorIndex > NsharpConstants.LINE_COMP10)
						colorIndex =NsharpConstants.LINE_COMP1;
					createRscPressTempCurveShape(world, soundingLayeys, lp);
				}
			}
		}
		else if(rscHandler.isOverlayIsOn() == true ){
			
			previousSoundingLys = rscHandler.getPreviousSoundingLys();
			createRscPressTempCurveShape(world, this.soundingLys, linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_OVERLAY1]));
			if(this.previousSoundingLys!=null && !previousSoundingLys.equals(soundingLys)){
				createRscPressTempCurveShape(world, this.previousSoundingLys, linePropertyMap.get(NsharpConstants.lineNameArray[NsharpConstants.LINE_OVERLAY2]));
			}

		}
		else {
			
			createRscPressTempCurveShape(world, this.soundingLys, null);
		}
	}
	
	public void createRscVTempTraceShape(){
		
		if((soundingLys == null) || (soundingLys.size()==0))
			return;
    	float t1;
    	if(vtempTraceCurveRscShape!=null){
			vtempTraceCurveRscShape.dispose();
			vtempTraceCurveRscShape=null;
		}
     
        Coordinate c2 =  null;
        Coordinate c1;
        // draw trace
        vtempTraceCurveRscShape = target.createWireframeShape(false,descriptor );
        vtempTraceCurveRscShape.allocate(this.soundingLys.size() * 2);
        for (NcSoundingLayer layer : this.soundingLys) {
        	if ((layer.getTemperature() != NsharpNativeConstants.NSHARP_NATIVE_INVALID_DATA) && (layer.getDewpoint() != NsharpNativeConstants.NSHARP_NATIVE_INVALID_DATA) && layer.getPressure()>= 100){
        		t1 = nsharpNative.nsharpLib.ivtmp(layer.getPressure());

        		c1 = NsharpWxMath.getSkewTXY(layer.getPressure(), t1);
        		c1.x = world.mapX(c1.x);
        		c1.y = world.mapY(c1.y);
        		if(c2!= null){
        			//target.drawLine(c1.x, c1.y, 0.0, c2.x, c2.y, 0.0, color,
        	  		//	lineWidth, LineStyle.DASHED);
        			double [][] lines = {{c1.x, c1.y},{c2.x, c2.y}};
        			vtempTraceCurveRscShape.addLineSegment(lines);
        		}
        		c2 =  c1;
        	}
        }
        vtempTraceCurveRscShape.compile();
	}
	/*
	 * Chin:: NOTE:::
	 * This plotting function is based on the algorithm of draw_Clouds() at xwvid1.c of AWC Nsharp source code
	 * Using Fred Mosher's Algorithm & Chernykh and Eskridge Algorithm 
	 * 
	 */
	private void createCloudsShape() {
    	NsharpNative.NsharpLibrary.CloudInfoStr cloudInfo = new NsharpNative.NsharpLibrary.CloudInfoStr();
    	nsharpNative.nsharpLib.draw_Clouds(cloudInfo);
    	// draw FM model: Fred Mosher's Algorithm
    	if(cloudInfo.getSizeFM() > 0){
    		cloudFMShape = target.createShadedShape(false, descriptor, false);
    		cloudFMLabelShape = target.createWireframeShape(false,descriptor );
    		cloudFMLabelShape.allocate(2);
    		double [][] lines = {{0, 0},{0,0}}; 
    		cloudFMLabelShape.addLineSegment(lines);
    		for (int i=0; i < cloudInfo.getSizeFM() ; i++){
    			double lowY = world.mapY(NsharpWxMath.getSkewTXY(cloudInfo.getPreStartFM()[i], -50).y);
    			double highY = world.mapY(NsharpWxMath.getSkewTXY(cloudInfo.getPreEndFM()[i], -50).y);
    			Coordinate[] coords = new Coordinate[4];
    			coords[0] = new Coordinate(skewtXOrig+150, lowY);
    			coords[1] = new Coordinate(skewtXOrig+200, lowY);
    			coords[2] = new Coordinate(skewtXOrig+200, highY);
    			coords[3] = new Coordinate(skewtXOrig+150, highY);
    			 			
    			/*
    			 * Create LineString[] from Coordinates[]
    			 */
    			GeometryFactory gf = new GeometryFactory();
    			LineString[] ls = new LineString[] { gf.createLineString(coords) };
    			
    			cloudFMShape.addPolygonPixelSpace(ls, NsharpConstants.color_yellow);      	
    			double [] lblXy = { skewtXOrig+175, (lowY+highY)/2};
    			cloudFMLabelShape.addLabel(NsharpNative.NsharpLibrary.CLOUD_TYPE[cloudInfo.cloudTypeFM[i]], lblXy);
    		}
    		cloudFMShape.compile();
    		cloudFMLabelShape.compile();
    	}
    	// draw CE model :  Chernykh and Eskridge Algorithm 
    	if(cloudInfo.getSizeCE() > 0){
    		cloudCEShape = target.createShadedShape(false, descriptor, false);
    		
    		for (int i=0; i < cloudInfo.getSizeCE() ; i++){
    			double lowY = world.mapY(NsharpWxMath.getSkewTXY(cloudInfo.getPreStartCE()[i], -50).y);
    			double highY = world.mapY(NsharpWxMath.getSkewTXY(cloudInfo.getPreEndCE()[i], -50).y);
    			Coordinate[] coords = new Coordinate[4];
    			coords[0] = new Coordinate(skewtXOrig+100, lowY);
    			coords[1] = new Coordinate(skewtXOrig+150, lowY);
    			coords[2] = new Coordinate(skewtXOrig+150, highY);
    			coords[3] = new Coordinate(skewtXOrig+100, highY);
    			 			
    			/*
    			 * Create LineString[] from Coordinates[]
    			 */
    			GeometryFactory gf = new GeometryFactory();
    			LineString[] ls = new LineString[] { gf.createLineString(coords) };
    			
    			cloudCEShape.addPolygonPixelSpace(ls, NsharpConstants.color_red);      	
    			
    		}
    		cloudCEShape.compile();
    		
    	}
    }

	/**
	 * Create all wire frame shapes at one place.
	 * Should be used only when a new resource is becoming Current active resource to be displayed.
	 *  
	 */
	
	public void createRscWireFrameShapes(){
		//System.out.println("createRscWireFrameShapes called");
		if(target!=null){
			disposeRscWireFrameShapes();
			if(soundingLys != null){
				createRscHeightMarkShape();
				createRscwetBulbTraceShape();
				createRscPressTempCurveShapeAll();
				createRscVTempTraceShape();
				List<ParcelData> parcelList  = rscHandler.getParcelList();
				for (ParcelData parData: parcelList){
					createRscParcelTraceShape(  parData.parcelType,parData.parcelLayerPressure);
				}
				createCloudsShape();
			}
		}
	}
	
	public void disposeRscWireFrameShapes(){
		if(heightMarkRscShape!=null){
			heightMarkRscShape.dispose();
			heightMarkRscShape=null;
		}
		if(wetBulbTraceRscShape!=null){
			wetBulbTraceRscShape.dispose();
			wetBulbTraceRscShape=null;
		}
		if(vtempTraceCurveRscShape!=null){
			vtempTraceCurveRscShape.dispose();
			vtempTraceCurveRscShape=null;
		}
		if(cloudFMShape!=null){
			cloudFMShape.dispose();
			cloudFMShape=null;
		}
		if(cloudCEShape!=null){
			cloudCEShape.dispose();
			cloudCEShape=null;
		}
		if(cloudFMLabelShape!=null){
			cloudFMLabelShape.dispose();
			cloudFMLabelShape=null;
		}
		if(icingTempShape!=null){
			icingTempShape.dispose();
			icingTempShape= null;
		}
		if(icingRHShape!=null){
			icingRHShape.dispose();
			icingRHShape=null;
		}
		if(icingEPIShape!=null){
			icingEPIShape.dispose();
			icingEPIShape=null;
		}
		if(turbWindShearShape!=null){
			turbWindShearShape.dispose();
			turbWindShearShape=null;
		}
		if(turbLnShape!=null){
			turbLnShape.dispose();
			turbLnShape=null;
		}
		if(parcelTraceRscShapeList.size()>0){
			for(IWireframeShape shape: parcelTraceRscShapeList){
				shape.dispose();
			}
			parcelTraceRscShapeList.clear();

		}

		if(pressureTempRscShapeList.size()>0){
			for(NsharpShapeAndLineProperty shapeColor: pressureTempRscShapeList){
				shapeColor.getShape().dispose();
			}
			pressureTempRscShapeList.clear();

		}
	}
	/*
	 * Return the closest point to the input point on either Temp or Dewpoint trace line
	 * Also set currentSoundingLayerIndex for plotting later
	 */
	public Coordinate getPickedTempPoint(Coordinate c){
		
		//System.out.println("picked pt X "+ x + " Y "+ y);
		//System.out.println("picked pt CX "+ c.x + " CY "+ c.y);
		
		
		Coordinate inC = NsharpWxMath.reverseSkewTXY(world.unMap(c));
		double inPressure = inC.y;
		double inTemp = inC.x;
		//System.out.println("user inout pt pressure "+ inPressure+ " temp "+inTemp  );
		double prevPressure=1000;
		double prevT=0, prevD=0;
		Coordinate closeptC = new Coordinate(1,1,0);
		boolean firstPrevPicked= false;
		
		/*
		 * Note: soundingLys list sorted with highest pressure as first element
		 */		
		
		for (NcSoundingLayer layer : this.soundingLys) {
			double t, d;
			t = layer.getTemperature();
			d = layer.getDewpoint();
			double pressure = layer.getPressure();
			if(firstPrevPicked==false){
				// this is to handle the case, if picked point has same pressure (largest pressure) as first layer 
				firstPrevPicked = true;
				prevPressure = pressure;
				prevT = t;
				prevD = d;
			}
			//System.out.println(" pressure "+ pressure );
			if(  pressure >= 100 && pressure <=  inPressure){
				// decide which pressure (layer) should be used. current one or previous one
				double disCurrentP =  Math.abs(pressure -inPressure );
				double disPreviousP =  Math.abs(prevPressure -inPressure );
				double pickedPressure, pickedTemp, pickedDewpoint;
				if(disPreviousP <= disCurrentP){
					pickedPressure = prevPressure;
					pickedTemp = prevT;
					pickedDewpoint = prevD;
					if(this.soundingLys.indexOf(layer) == 0)
						currentSoundingLayerIndex = this.soundingLys.indexOf(layer);
					else
						currentSoundingLayerIndex = this.soundingLys.indexOf(layer)-1;
				}
				else {
					pickedPressure = pressure;
					pickedTemp = t;
					pickedDewpoint = d;
					currentSoundingLayerIndex = this.soundingLys.indexOf(layer);
				}
				//decide which line, temp or dewpoint, closer to user picked point
				double disTemp = Math.abs(pickedTemp- inTemp);
				double disDew = Math.abs(pickedDewpoint- inTemp);
				if(disTemp <= disDew){
					closeptC =  NsharpWxMath.getSkewTXY(pickedPressure, pickedTemp);
					closeptC = world.map(closeptC);
					currentTempCurveType = TEMP_TYPE;	
					//System.out.println("picked pressure "+ pickedPressure + " temp " +pickedTemp);
				}
				else {
					closeptC =  NsharpWxMath.getSkewTXY(pickedPressure, pickedDewpoint);
					closeptC = world.map(closeptC);
					currentTempCurveType = DEWPOINT_TYPE;
					//System.out.println("picked pressure "+ pickedPressure + " dewpoint " +pickedDewpoint);
				}
				
				//System.out.println("currentSoundingLayerIndex P = "+ this.soundingLys.get(currentSoundingLayerIndex).getPressure());
				break;
			}			
			prevPressure = pressure;
			prevT = t;
			prevD = d;
		}
		
		return closeptC;
	}
	public void setCursorInSkewT(boolean cursorInSkewT) {
		this.cursorInSkewT = cursorInSkewT;
	}
	public void toggleCurseDisplay() {
		curseToggledFontLevel = curseToggledFontLevel + CURSER_FONT_INC_STEP;
		if(curseToggledFontLevel > CURSER_STRING_OFF)
			curseToggledFontLevel = CURSER_FONT_10;
		/*NsharpEditor editor = NsharpEditor.getActiveNsharpEditor();
		if (editor != null) {
			editor.refresh();
		}*/
		rscHandler.refreshPane();
	}

	public NsharpSkewTPaneBackground getSkewTBackground() {
		return skewTBackground;
	}

	public NsharpIcingPaneBackground getIcingBackground() {
		return icingBackground;
	}

	public NsharpTurbulencePaneBackground getTurbBackground() {
		return turbBackground;
	}
	public NsharpGenericPaneBackground getActiveBackground(){
		if(currentGraphMode == NsharpConstants.GRAPH_SKEWT){
			return skewTBackground;
		}
		else if(currentGraphMode == NsharpConstants.GRAPH_ICING){
			return icingBackground;
		}
		else if(currentGraphMode == NsharpConstants.GRAPH_TURB){
			return turbBackground;
		}
		return null;
	}
	public void setCurrentGraphMode(int currentGraphMode) {
		this.currentGraphMode = currentGraphMode;
		rscHandler.getWitoPaneRsc().handleResize();
	}

	public void setPlotInteractiveTemp(boolean plotInteractiveTemp) {
		this.plotInteractiveTemp = plotInteractiveTemp;
	}

	public void setInteractiveTempPointCoordinate(
			Coordinate interactiveTempPointCoordinate) {
		this.interactiveTempPointCoordinate = interactiveTempPointCoordinate;
	}

	public int getCurrentTempCurveType() {
		return currentTempCurveType;
	}

	@Override
	public void handleResize() {
		
		super.handleResize();
		IExtent ext = getDescriptor().getRenderableDisplay().getExtent();
		ext.reset();
		//System.out.println("skewtPane: handleResize");
   	 	this.rectangle = new Rectangle((int)ext.getMinX(), (int) ext.getMinY(),
   			 (int) ext.getWidth(), (int) ext.getHeight());
        pe = new PixelExtent(this.rectangle);
		getDescriptor().setNewPe(pe);
		world = new WGraphics(this.rectangle);
		world.setWorldCoordinates(NsharpConstants.left, NsharpConstants.top,
				NsharpConstants.right, NsharpConstants.bottom);
		float prevHeight = skewtHeight;
		float prevWidth = skewtWidth;
		skewtXOrig = (int) (ext.getMinX());
		skewtYOrig = (int) ext.getMinY();
		skewtWidth = (int) (ext.getWidth());
		skewtHeight = (int) ext.getHeight();
		skewtXEnd = skewtXOrig+ skewtWidth;
		skewtYEnd = skewtYOrig+ skewtHeight;
		xRatio = xRatio* skewtWidth/prevWidth;
		yRatio = yRatio* skewtHeight/prevHeight;
		createRscWireFrameShapes();
		skewTBackground.handleResize(ext);
		turbBackground.handleResize(ext);
		icingBackground.handleResize(ext);
		//System.out.println(descriptor.getPaneNumber()+":calling wito handle resize");
		rscHandler.getWitoPaneRsc().handleResize();
	}

	@Override
	public void handleZooming() {
		if(heightMarkRscShape!=null)
			heightMarkRscShape.dispose();
		createRscHeightMarkShape();
		skewTBackground.handleZooming();
		turbBackground.handleZooming();
		icingBackground.handleZooming();
		rscHandler.getWitoPaneRsc().handleZooming();

	}

	@Override
	protected void adjustFontSize(int canvasW, int canvasH) {
		// TODO Auto-generated method stub
		super.adjustFontSize(canvasW, canvasH);
		//make a bit bigger font10 size for skewT
		float font10Size=10;
		if(font10!=null){
			font10Size = font10.getFontSize()+1;
			font10.dispose();
		}
		font10 = target.initializeFont("Monospace", font10Size, null);
	}
	
}
