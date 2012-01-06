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
package com.raytheon.uf.viz.d2d.gfe.browser;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.raytheon.uf.common.dataplugin.gfe.db.objects.ParmID;
import com.raytheon.uf.common.dataquery.requests.RequestConstraint;
import com.raytheon.uf.common.dataquery.requests.RequestConstraint.ConstraintType;
import com.raytheon.uf.viz.core.catalog.CatalogQuery;
import com.raytheon.uf.viz.core.exception.VizException;
import com.raytheon.uf.viz.core.rsc.DisplayType;
import com.raytheon.uf.viz.core.rsc.ResourceType;
import com.raytheon.uf.viz.core.rsc.capabilities.DisplayTypeCapability;
import com.raytheon.uf.viz.d2d.gfe.GFEUtil;
import com.raytheon.uf.viz.d2d.gfe.rsc.GFEGridResourceData;
import com.raytheon.uf.viz.productbrowser.AbstractRequestableProductBrowserDataDefinition;
import com.raytheon.uf.viz.productbrowser.ProductBrowserLabel;
import com.raytheon.uf.viz.productbrowser.ProductBrowserPreference;
import com.raytheon.viz.grid.rsc.GridLoadProperties;

/**
 * 
 * TODO Add Description
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Mar 9, 2011            bsteffen     Initial creation
 * 
 * </pre>
 * 
 * @author bsteffen
 * @version 1.0
 */
public class GFEDataDefinition extends
        AbstractRequestableProductBrowserDataDefinition<GFEGridResourceData> {

    public static final String SITE_ID = "siteId";

    public static final String DB_TYPE = "dbType";

    public static final String MODEL_NAME = "modelName";

    public static final String MODEL_TIME = "modelTime";

    public static final String PARM_NAME = "parmName";

    public static final String PARM_LEVEL = "parmLevel";

    public GFEDataDefinition() {
        productName = "gfe";
        displayName = "GFE";
        order = new String[] { GFEUtil.PLUGIN_NAME, SITE_ID, MODEL_NAME,
                PARM_NAME, PARM_LEVEL };
        order = getOrder();
        loadProperties = new GridLoadProperties();
        loadProperties.setResourceType(getResourceType());
    }

    @Override
    public GFEGridResourceData getResourceData() {
        resourceData = new GFEGridResourceData();
        loadProperties = new GridLoadProperties(loadProperties
                .getCapabilities()
                .getCapability(resourceData, DisplayTypeCapability.class)
                .getDisplayType());
        loadProperties.setResourceType(getResourceType());
        return resourceData;
    }

    @Override
    public Map<ResourceType, List<DisplayType>> getDisplayTypes() {
        Map<ResourceType, List<DisplayType>> type = new HashMap<ResourceType, List<DisplayType>>();
        List<DisplayType> types = new ArrayList<DisplayType>();
        types.add(DisplayType.CONTOUR);
        types.add(DisplayType.IMAGE);
        type.put(ResourceType.PLAN_VIEW, types);
        return type;
    }

    /*
     * (non-Javadoc)
     * 
     * @see com.raytheon.uf.viz.productbrowser.
     * AbstractRequestableProductBrowserDataDefinition
     * #buildProductList(java.util.List)
     */
    @Override
    public List<String> buildProductList(List<String> historyList) {
        String[] parameters = getParmIds(getProductParameters(new String[0],
                null));
        List<String> result = new ArrayList<String>();
        for (String orderString : order) {
            if (orderString == order[0]) {
                continue;
            }
            List<ProductBrowserLabel> labels = formatData(orderString,
                    parameters);
            for (ProductBrowserLabel label : labels) {
                if (!result.contains(label.getName())) {
                    result.add(label.getName());
                }
            }
        }
        return Collections.emptyList();
    }

    @Override
    public String populateInitial() {
        if (!isEnabled()) {
            return null;
        }
        String[] parameters = getParmIds(getProductParameters(new String[0],
                null));

        if (parameters != null) {
            if (parameters.length > 0) {
                return displayName;
            } else {
                return null;
            }
        } else {
            return null;
        }

    }

    @Override
    public List<ProductBrowserLabel> populateData(String[] selection) {
        List<ProductBrowserLabel> parameters = null;
        boolean product = false;
        String param = order[selection.length];

        if (selection.length == order.length - 1) {
            product = true;
        }

        String[] temp = getParmIds(getProductParameters(selection, null));
        parameters = formatData(param, temp);
        if (parameters != null) {
            for (ProductBrowserLabel label : parameters) {
                label.setProduct(product);
                label.setDefinition(this);
            }
        }
        return parameters;
    }

    @Override
    public List<ProductBrowserLabel> formatData(String param,
            String[] parameters) {
        Set<ProductBrowserLabel> labels = new HashSet<ProductBrowserLabel>();
        for (String value : parameters) {
            String label = value;
            try {
                ParmID parmId = new ParmID(value);
                if (param.equals(SITE_ID)) {
                    label = parmId.getDbId().getSiteId();
                } else if (param.equals(MODEL_NAME)) {
                    label = parmId.getDbId().getModelName();
                } else if (param.equals(MODEL_TIME)) {
                    label = parmId.getDbId().getModelTime();
                } else if (param.equals(DB_TYPE)) {
                    label = parmId.getDbId().getDbType();
                } else if (param.equals(PARM_NAME)) {
                    label = parmId.getParmName();
                } else if (param.equals(PARM_LEVEL)) {
                    label = parmId.getParmLevel();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            labels.add(new ProductBrowserLabel(label, label));
        }
        ArrayList<ProductBrowserLabel> finalLabels = new ArrayList<ProductBrowserLabel>(
                labels);
        Collections.sort(finalLabels);
        return finalLabels;
    }

    private String[] getParmIds(Map<String, RequestConstraint> queryList) {
        String param = GFEUtil.PARM_ID;
        try {
            return CatalogQuery.performQuery(param, queryList);
        } catch (VizException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public HashMap<String, RequestConstraint> getProductParameters(
            String[] selection, String[] order) {
        if (order == null) {
            order = this.order;
        }
        String siteId = "%";
        String modelName = "%";
        String modelTime = "%";
        String dbType = "%";
        String parmName = "%";
        String parmLevel = "%";

        HashMap<String, RequestConstraint> queryList = new HashMap<String, RequestConstraint>();
        queryList.put(order[0], new RequestConstraint(productName));
        for (int i = 1; i < selection.length; i++) {
            if (order[i].equals(SITE_ID)) {
                siteId = selection[i];
            } else if (order[i].equals(MODEL_NAME)) {
                modelName = selection[i];
            } else if (order[i].equals(MODEL_TIME)) {
                modelTime = selection[i];
            } else if (order[i].equals(DB_TYPE)) {
                dbType = selection[i];
            } else if (order[i].equals(PARM_NAME)) {
                parmName = selection[i];
            } else if (order[i].equals(PARM_LEVEL)) {
                parmLevel = selection[i];
            }
        }
        String parmId = String.format(GFEUtil.PARM_ID_FORMAT, parmName,
                parmLevel, siteId, dbType, modelName, modelTime);
        queryList.put(GFEUtil.PARM_ID, new RequestConstraint(parmId,
                ConstraintType.LIKE));
        return queryList;
    }

    /*
     * (non-Javadoc)
     * 
     * @see com.raytheon.uf.viz.productbrowser.xml.IProductBrowserPreferences#
     * configurePreferences()
     */
    @Override
    public List<ProductBrowserPreference> configurePreferences() {
        return super.configurePreferences();
    }
}
