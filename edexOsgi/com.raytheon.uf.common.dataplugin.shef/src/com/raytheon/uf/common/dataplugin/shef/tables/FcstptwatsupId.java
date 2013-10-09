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
package com.raytheon.uf.common.dataplugin.shef.tables;
// default package
// Generated Oct 17, 2008 2:22:17 PM by Hibernate Tools 3.2.2.GA

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * FcstptwatsupId generated by hbm2java
 * 
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Oct 17, 2008                        Initial generation by hbm2java
 * Aug 19, 2011      10672     jkorman Move refactor to new project
 * Oct 07, 2013       2361     njensen Removed XML annotations
 * 
 * </pre>
 * 
 * @author jkorman
 * @version 1.1
 */
@Embeddable
@com.raytheon.uf.common.serialization.annotations.DynamicSerialize
public class FcstptwatsupId extends com.raytheon.uf.common.dataplugin.persist.PersistableDataObject implements java.io.Serializable {

    private static final long serialVersionUID = 1L;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String lid;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String watsupMethod;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String watsupCoordAgency;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String frequpdNormal;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String periodReq;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String watsupCrit;

    public FcstptwatsupId() {
    }

    public FcstptwatsupId(String lid, String watsupMethod,
            String watsupCoordAgency, String frequpdNormal, String periodReq,
            String watsupCrit) {
        this.lid = lid;
        this.watsupMethod = watsupMethod;
        this.watsupCoordAgency = watsupCoordAgency;
        this.frequpdNormal = frequpdNormal;
        this.periodReq = periodReq;
        this.watsupCrit = watsupCrit;
    }

    @Column(name = "lid", nullable = false, length = 8)
    public String getLid() {
        return this.lid;
    }

    public void setLid(String lid) {
        this.lid = lid;
    }

    @Column(name = "watsup_method", nullable = false, length = 50)
    public String getWatsupMethod() {
        return this.watsupMethod;
    }

    public void setWatsupMethod(String watsupMethod) {
        this.watsupMethod = watsupMethod;
    }

    @Column(name = "watsup_coord_agency", nullable = false, length = 64)
    public String getWatsupCoordAgency() {
        return this.watsupCoordAgency;
    }

    public void setWatsupCoordAgency(String watsupCoordAgency) {
        this.watsupCoordAgency = watsupCoordAgency;
    }

    @Column(name = "frequpd_normal", nullable = false, length = 30)
    public String getFrequpdNormal() {
        return this.frequpdNormal;
    }

    public void setFrequpdNormal(String frequpdNormal) {
        this.frequpdNormal = frequpdNormal;
    }

    @Column(name = "period_req", nullable = false, length = 30)
    public String getPeriodReq() {
        return this.periodReq;
    }

    public void setPeriodReq(String periodReq) {
        this.periodReq = periodReq;
    }

    @Column(name = "watsup_crit", nullable = false, length = 30)
    public String getWatsupCrit() {
        return this.watsupCrit;
    }

    public void setWatsupCrit(String watsupCrit) {
        this.watsupCrit = watsupCrit;
    }

    public boolean equals(Object other) {
        if ((this == other))
            return true;
        if ((other == null))
            return false;
        if (!(other instanceof FcstptwatsupId))
            return false;
        FcstptwatsupId castOther = (FcstptwatsupId) other;

        return ((this.getLid() == castOther.getLid()) || (this.getLid() != null
                && castOther.getLid() != null && this.getLid().equals(
                castOther.getLid())))
                && ((this.getWatsupMethod() == castOther.getWatsupMethod()) || (this
                        .getWatsupMethod() != null
                        && castOther.getWatsupMethod() != null && this
                        .getWatsupMethod().equals(castOther.getWatsupMethod())))
                && ((this.getWatsupCoordAgency() == castOther
                        .getWatsupCoordAgency()) || (this
                        .getWatsupCoordAgency() != null
                        && castOther.getWatsupCoordAgency() != null && this
                        .getWatsupCoordAgency().equals(
                                castOther.getWatsupCoordAgency())))
                && ((this.getFrequpdNormal() == castOther.getFrequpdNormal()) || (this
                        .getFrequpdNormal() != null
                        && castOther.getFrequpdNormal() != null && this
                        .getFrequpdNormal()
                        .equals(castOther.getFrequpdNormal())))
                && ((this.getPeriodReq() == castOther.getPeriodReq()) || (this
                        .getPeriodReq() != null
                        && castOther.getPeriodReq() != null && this
                        .getPeriodReq().equals(castOther.getPeriodReq())))
                && ((this.getWatsupCrit() == castOther.getWatsupCrit()) || (this
                        .getWatsupCrit() != null
                        && castOther.getWatsupCrit() != null && this
                        .getWatsupCrit().equals(castOther.getWatsupCrit())));
    }

    public int hashCode() {
        int result = 17;

        result = 37 * result
                + (getLid() == null ? 0 : this.getLid().hashCode());
        result = 37
                * result
                + (getWatsupMethod() == null ? 0 : this.getWatsupMethod()
                        .hashCode());
        result = 37
                * result
                + (getWatsupCoordAgency() == null ? 0 : this
                        .getWatsupCoordAgency().hashCode());
        result = 37
                * result
                + (getFrequpdNormal() == null ? 0 : this.getFrequpdNormal()
                        .hashCode());
        result = 37 * result
                + (getPeriodReq() == null ? 0 : this.getPeriodReq().hashCode());
        result = 37
                * result
                + (getWatsupCrit() == null ? 0 : this.getWatsupCrit()
                        .hashCode());
        return result;
    }

}
