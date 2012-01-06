package gov.noaa.nws.ncep.viz.resourceManager.ui.newResource;

import java.util.ArrayList;

import gov.noaa.nws.ncep.viz.resourceManager.ui.createRbd.ResourceSelectionDialog;
import gov.noaa.nws.ncep.viz.resourceManager.ui.createRbd.ResourceSelectionControl.IResourceSelectedListener;
import gov.noaa.nws.ncep.viz.resources.AbstractNatlCntrsRequestableResourceData;
import gov.noaa.nws.ncep.viz.resources.manager.ResourceDefnsMngr;
import gov.noaa.nws.ncep.viz.resources.manager.ResourceFactory;
import gov.noaa.nws.ncep.viz.resources.manager.ResourceName;
import gov.noaa.nws.ncep.viz.resources.manager.ResourceFactory.ResourceSelection;
import gov.noaa.nws.ncep.viz.resources.time_match.NCTimeMatcher;
import gov.noaa.nws.ncep.viz.ui.display.NCDisplayPane;
import gov.noaa.nws.ncep.viz.ui.display.NCMapEditor;
import gov.noaa.nws.ncep.viz.ui.display.NCMapRenderableDisplay;
import gov.noaa.nws.ncep.viz.ui.display.NmapUiUtils;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Shell;

import com.raytheon.uf.common.time.DataTime;
import com.raytheon.uf.viz.core.IDisplayPane;
import com.raytheon.uf.viz.core.drawables.IDescriptor;
import com.raytheon.uf.viz.core.drawables.ResourcePair;
import com.raytheon.uf.viz.core.exception.VizException;
import com.raytheon.uf.viz.core.map.MapDescriptor;
import com.raytheon.uf.viz.core.rsc.AbstractResourceData;
import com.raytheon.uf.viz.core.rsc.AbstractVizResource;
import com.raytheon.uf.viz.core.rsc.LoadProperties;
import com.raytheon.uf.viz.core.rsc.ResourceList;
import com.raytheon.uf.viz.core.rsc.ResourceProperties;

/**
 *  Select a new resource from the main menu and add to the active editor. 
 * 
 * <pre>
 * SOFTWARE HISTORY
 * Date         Ticket#     Engineer    Description
 * ------------ ----------  ----------- --------------------------
 * 04/18/11      #           Greg Hull    Initial Creation.
 * 06/07/11       #445       Xilin Guo   Data Manager Performance Improvements
 * 
 * </pre>
 * 
 * @author ghull
 * @version 1
 */
public class NewResourceAction extends AbstractHandler {

	private Shell shell=null;
	
	
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {

		shell = NmapUiUtils.getCaveShell();
		
		final NCMapEditor editor = NmapUiUtils.getActiveNatlCntrsEditor();
		
		if( editor == null ) {
    		MessageDialog errDlg = new MessageDialog( 
    				NmapUiUtils.getCaveShell(), 
    				"Error", null, 
    				"Can't load resource to this type of Display",
    				MessageDialog.ERROR, new String[]{"OK"}, 0);
    		errDlg.open();
    		return null;
		}

		NCMapRenderableDisplay display = 
			   (NCMapRenderableDisplay) editor.getSelectedPane().getRenderableDisplay();
		
		final NCTimeMatcher timeMatcher = 
			(NCTimeMatcher) display.getDescriptor().getTimeMatcher();
		
		if( timeMatcher == null ) { // sanity check
			
			// TODO ? show an info message that there is no timeline and that the
			// selected resource will be dominant and use its default timeline?
//			timeMatcher.getFrameTimes() == null ||
//			timeMatcher.getFrameTimes().isEmpty()  ) {
			
    		MessageDialog errDlg = new MessageDialog( 
    				NmapUiUtils.getCaveShell(), 
    				"Error", null, 
    				"Can't load resource to a Display with no selected timeline",
    				MessageDialog.ERROR, new String[]{"OK"}, 0);
    		errDlg.open();
    		return null;
		}

		final boolean useNewTimeMatcher = (timeMatcher.getFrameTimes() == null ||
										   timeMatcher.getFrameTimes().isEmpty());
				

		// Create the Selection Dialog and add a listener for when a resource is selected.
		// 
		final ResourceSelectionDialog rscSelDlg = new ResourceSelectionDialog( shell ); 
				
   		rscSelDlg.addResourceSelectionListener( new IResourceSelectedListener() {
   			@Override
   			public void resourceSelected( ResourceName rscName, DataTime fcstTime, boolean done ) {
   				try {
//   	   			System.out.println("Loading Resource " + rscName );   	   				
   					ResourceSelection rscSel = ResourceFactory.createResource( rscName );
   					ResourcePair rscPair = rscSel.getResourcePair();
   					AbstractResourceData rscData = rscPair.getResourceData();
   					LoadProperties ldProp = rscPair.getLoadProperties();
   					ResourceProperties rscProp = rscPair.getProperties();
   	   				
   					// if there is no data for this resource then don't load the resource.
   					// 
   					if( rscData instanceof AbstractNatlCntrsRequestableResourceData ) {

   						ArrayList<DataTime> availTimes = 
   							((AbstractNatlCntrsRequestableResourceData) rscData).getAvailableDataTimes();

   						if( availTimes == null || availTimes.isEmpty() ) {

   							MessageDialog msgDlg = new MessageDialog( 
   									shell, "No Data", null, 
   									"There is no data available for this resource.",
   									MessageDialog.INFORMATION, new String[]{"Ok"}, 0);
   							msgDlg.open();
   							rscSelDlg.close();
   							return;
   						}
   					
   	   					// if no timeline is set then use the selected resource as the dominant 
   	   					// resource.
   						// This timeMatcher is shared between all panes so there is no need 
   						// to this timeMatcher to other panes.
   	   					if( useNewTimeMatcher ) {
   	   						
   	   						timeMatcher.setDominantResourceData( 
   	   							(AbstractNatlCntrsRequestableResourceData) rscData );
   	   						timeMatcher.updateFromDominantResource();   	   						
   	   					}
   	   					

   	   					{ // check that available data time matches to the timeline....

   						}

   					}   	   					

   	   				// add the selected resource to the resource list for each pane
   					//
   	   				for( IDisplayPane pane : editor.getSelectedPanes() ) {    			

   	   					IDescriptor mapDescr = pane.getDescriptor();
   	   					
   	   					if( useNewTimeMatcher ) {
   	   						mapDescr.setTimeMatcher( timeMatcher ); 
   	   						mapDescr.setNumberOfFrames( timeMatcher.getNumFrames() );
   	   						DataTime[] dataTimes = timeMatcher.getFrameTimes().toArray( new DataTime[0] );

   	   						if( dataTimes == null || dataTimes.length == 0 ) {
   	   							
   	   						}
   	   						else {
   	   							mapDescr.setDataTimes( dataTimes );
   	   						}
   	   						
   	   						if( timeMatcher.isForecast() ) {
   	   							mapDescr.setFrame( 0 );
   	   						}
   	   						else {
   	   							mapDescr.setFrame( dataTimes.length-1 );
   	   						}

   	   					}
   	   					
   	   					ResourceList rscList = mapDescr.getResourceList();

   	   					AbstractVizResource<?,?> rsc = rscData.construct( ldProp, mapDescr);
   	   					
   	   					rscList.add( rsc, rscProp );
   	   				}   

   	   				editor.refresh();
   	   				editor.refreshGUIElements();
   				}
   				catch (VizException e ) {
   					System.out.println( "Error Adding Resource to List: " + e.getMessage() );
					MessageDialog errDlg = new MessageDialog( 
							shell, "Error", null, 
							"Error Creating Resource:"+rscName.toString()+"\n\n"+e.getMessage(),
							MessageDialog.ERROR, new String[]{"OK"}, 0);
					errDlg.open();
   				}
   				
//   				if( done ) {
   					rscSelDlg.close();
//   				}
   			}
   		});

   		// generate any new dynamic resources and open the Selection Dialog
   		//
//      xguo,06/02/11. To enhance the system performance, move 
//      data resource query into NC-Perspective initialization
//   		try {
//   			ResourceDefnsMngr rscDefnsMngr = ResourceDefnsMngr.getInstance();
//   			rscDefnsMngr.generateDynamicResources();

//   	   		rscSelDlg.open( " Load Resource ",
//   					SWT.DIALOG_TRIM | SWT.RESIZE | SWT.APPLICATION_MODAL );   					

//   		} catch (VizException e1) {
//   			MessageDialog errDlg = new MessageDialog( 
//   					shell, "Error", null, 
//   					"Error reading Resource Definitions Table",
//   					MessageDialog.ERROR, new String[]{"Ok"}, 0);
//   			errDlg.open();
//   		}
   		rscSelDlg.open( " Load Resource ",
				SWT.DIALOG_TRIM | SWT.RESIZE | SWT.APPLICATION_MODAL );
		return null;
	}
}
