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

import java.util.HashSet;
import java.util.Set;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

/**
 * Frequencyupdate generated by hbm2java
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
@Entity
@Table(name = "frequencyupdate")
@com.raytheon.uf.common.serialization.annotations.DynamicSerialize
public class Frequencyupdate extends com.raytheon.uf.common.dataplugin.persist.PersistableDataObject implements java.io.Serializable {

    private static final long serialVersionUID = 1L;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String frequencyUpdate;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Set<Fcstptesp> fcstptespsForFrequpdNormal = new HashSet<Fcstptesp>(
            0);

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Set<Fcstptdeterm> fcstptdetermsForFrequpdNormal = new HashSet<Fcstptdeterm>(
            0);

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Set<Fcstptesp> fcstptespsForFrequpdDrought = new HashSet<Fcstptesp>(
            0);

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Set<Fcstptdeterm> fcstptdetermsForFrequpdFlood = new HashSet<Fcstptdeterm>(
            0);

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Set<Fcstptwatsup> fcstptwatsups = new HashSet<Fcstptwatsup>(0);

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Set<Fcstptdeterm> fcstptdetermsForFrequpdDrought = new HashSet<Fcstptdeterm>(
            0);

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Set<Fcstptesp> fcstptespsForFrequpdFlood = new HashSet<Fcstptesp>(0);

    public Frequencyupdate() {
    }

    public Frequencyupdate(String frequencyUpdate) {
        this.frequencyUpdate = frequencyUpdate;
    }

    public Frequencyupdate(String frequencyUpdate,
            Set<Fcstptesp> fcstptespsForFrequpdNormal,
            Set<Fcstptdeterm> fcstptdetermsForFrequpdNormal,
            Set<Fcstptesp> fcstptespsForFrequpdDrought,
            Set<Fcstptdeterm> fcstptdetermsForFrequpdFlood,
            Set<Fcstptwatsup> fcstptwatsups,
            Set<Fcstptdeterm> fcstptdetermsForFrequpdDrought,
            Set<Fcstptesp> fcstptespsForFrequpdFlood) {
        this.frequencyUpdate = frequencyUpdate;
        this.fcstptespsForFrequpdNormal = fcstptespsForFrequpdNormal;
        this.fcstptdetermsForFrequpdNormal = fcstptdetermsForFrequpdNormal;
        this.fcstptespsForFrequpdDrought = fcstptespsForFrequpdDrought;
        this.fcstptdetermsForFrequpdFlood = fcstptdetermsForFrequpdFlood;
        this.fcstptwatsups = fcstptwatsups;
        this.fcstptdetermsForFrequpdDrought = fcstptdetermsForFrequpdDrought;
        this.fcstptespsForFrequpdFlood = fcstptespsForFrequpdFlood;
    }

    @Id
    @Column(name = "frequency_update", unique = true, nullable = false, length = 30)
    public String getFrequencyUpdate() {
        return this.frequencyUpdate;
    }

    public void setFrequencyUpdate(String frequencyUpdate) {
        this.frequencyUpdate = frequencyUpdate;
    }

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER, mappedBy = "frequencyupdateByFrequpdNormal")
    public Set<Fcstptesp> getFcstptespsForFrequpdNormal() {
        return this.fcstptespsForFrequpdNormal;
    }

    public void setFcstptespsForFrequpdNormal(
            Set<Fcstptesp> fcstptespsForFrequpdNormal) {
        this.fcstptespsForFrequpdNormal = fcstptespsForFrequpdNormal;
    }

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER, mappedBy = "frequencyupdateByFrequpdNormal")
    public Set<Fcstptdeterm> getFcstptdetermsForFrequpdNormal() {
        return this.fcstptdetermsForFrequpdNormal;
    }

    public void setFcstptdetermsForFrequpdNormal(
            Set<Fcstptdeterm> fcstptdetermsForFrequpdNormal) {
        this.fcstptdetermsForFrequpdNormal = fcstptdetermsForFrequpdNormal;
    }

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER, mappedBy = "frequencyupdateByFrequpdDrought")
    public Set<Fcstptesp> getFcstptespsForFrequpdDrought() {
        return this.fcstptespsForFrequpdDrought;
    }

    public void setFcstptespsForFrequpdDrought(
            Set<Fcstptesp> fcstptespsForFrequpdDrought) {
        this.fcstptespsForFrequpdDrought = fcstptespsForFrequpdDrought;
    }

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER, mappedBy = "frequencyupdateByFrequpdFlood")
    public Set<Fcstptdeterm> getFcstptdetermsForFrequpdFlood() {
        return this.fcstptdetermsForFrequpdFlood;
    }

    public void setFcstptdetermsForFrequpdFlood(
            Set<Fcstptdeterm> fcstptdetermsForFrequpdFlood) {
        this.fcstptdetermsForFrequpdFlood = fcstptdetermsForFrequpdFlood;
    }

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER, mappedBy = "frequencyupdate")
    public Set<Fcstptwatsup> getFcstptwatsups() {
        return this.fcstptwatsups;
    }

    public void setFcstptwatsups(Set<Fcstptwatsup> fcstptwatsups) {
        this.fcstptwatsups = fcstptwatsups;
    }

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER, mappedBy = "frequencyupdateByFrequpdDrought")
    public Set<Fcstptdeterm> getFcstptdetermsForFrequpdDrought() {
        return this.fcstptdetermsForFrequpdDrought;
    }

    public void setFcstptdetermsForFrequpdDrought(
            Set<Fcstptdeterm> fcstptdetermsForFrequpdDrought) {
        this.fcstptdetermsForFrequpdDrought = fcstptdetermsForFrequpdDrought;
    }

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER, mappedBy = "frequencyupdateByFrequpdFlood")
    public Set<Fcstptesp> getFcstptespsForFrequpdFlood() {
        return this.fcstptespsForFrequpdFlood;
    }

    public void setFcstptespsForFrequpdFlood(
            Set<Fcstptesp> fcstptespsForFrequpdFlood) {
        this.fcstptespsForFrequpdFlood = fcstptespsForFrequpdFlood;
    }

}
