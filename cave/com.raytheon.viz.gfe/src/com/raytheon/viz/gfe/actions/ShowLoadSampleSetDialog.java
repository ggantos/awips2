/**
 * This software was developed and / or modified by Raytheon Company,
 * pursuant to Contract DG133W-05-CQ-1067 with the US Government.
 * 
 * U.S. EXPORT CONTROLLED TECHNICAL DATA
 * This software product contains export-restricted data whose
 * export/transfer/disclosure is restricted by U.S. law. Dissemination
 * to non-U.S. persons whether in the United States or abroad requires
 * an export license or other authorization.
 * 
 * Contractor Name:        Raytheon Company
 * Contractor Address:     6825 Pine Street, Suite 340
 *                         Mail Stop B8
 *                         Omaha, NE 68106
 *                         402.291.0100
 * 
 * See the AWIPS II Master Rights File ("Master Rights File.pdf") for
 * further licensing information.
 **/
package com.raytheon.viz.gfe.actions;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;

import com.raytheon.uf.common.status.IUFStatusHandler;
import com.raytheon.uf.common.status.UFStatus;
import com.raytheon.viz.gfe.core.DataManager;
import com.raytheon.viz.gfe.core.DataManagerUIFactory;
import com.raytheon.viz.gfe.dialogs.LoadSampleSetDialog;

/**
 * Action to launch sampele set dialog.
 * 
 * <pre>
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Mar 7, 2008             Eric Babin  Initial Creation
 * Apr 9, 2009  1288       rjpeter     Removed explicit refresh of SpatialDisplayManager.
 * Oct 24, 2012 1287       rferrel     Changes for non-blocking SampleSetDialog.
 * Sep 15, 2014 3592       randerso    Move logic into dialog code.
 * 
 * </pre>
 * 
 * @author ebabin
 * @version 1.0
 */

public class ShowLoadSampleSetDialog extends AbstractHandler {
    private final transient IUFStatusHandler statusHandler = UFStatus
            .getHandler(ShowSaveDeleteSampleSetDialog.class);

    private LoadSampleSetDialog dialog;

    /*
     * (non-Javadoc)
     * 
     * @see
     * org.eclipse.core.commands.AbstractHandler#execute(org.eclipse.core.commands
     * .ExecutionEvent)
     */
    @Override
    public Object execute(ExecutionEvent event) throws ExecutionException {
        DataManager dm = DataManagerUIFactory.getCurrentInstance();
        if (dm == null) {
            return null;
        }

        if ((dialog == null) || (dialog.getShell() == null)
                || dialog.isDisposed()) {
            Shell shell = PlatformUI.getWorkbench().getActiveWorkbenchWindow()
                    .getShell();

            dialog = new LoadSampleSetDialog(dm.getSampleSetManager(), shell);

            dialog.setBlockOnOpen(false);
            dialog.open();
        } else {
            dialog.bringToTop();
        }

        return null;
    }

}
