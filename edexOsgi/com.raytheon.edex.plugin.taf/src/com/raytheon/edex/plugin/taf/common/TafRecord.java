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

package com.raytheon.edex.plugin.taf.common;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.PrimaryKeyJoinColumn;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

import org.hibernate.annotations.Index;

import com.raytheon.uf.common.dataplugin.IDecoderGettable;
import com.raytheon.uf.common.dataplugin.PluginDataObject;
import com.raytheon.uf.common.dataplugin.annotations.DataURI;
import com.raytheon.uf.common.geospatial.ISpatialEnabled;
import com.raytheon.uf.common.pointdata.spatial.ObStation;
import com.raytheon.uf.common.serialization.annotations.DynamicSerialize;
import com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement;

/**
 * Record implementation for taf plugin
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#     Engineer    Description
 * ------------ ----------  ----------- --------------------------
 * 2/14/07      139         bphillip    Initial Creation
 * 6/21/07      180         bphillip    Updated to use new plugin pattern   
 * 20071129            472  jkorman     Added IDecoderGettable interface.
 * 
 * </pre>
 * 
 * @author bphillip
 * @version 1
 */
@Entity
@Table(name = "taf", uniqueConstraints = { @UniqueConstraint(columnNames = { "dataURI" }) })
@DynamicSerialize
@XmlAccessorType(XmlAccessType.NONE)
@XmlRootElement
public class TafRecord extends PluginDataObject implements ISpatialEnabled {

    private static final long serialVersionUID = 1L;

    @DynamicSerializeElement
    @XmlElement
    @Column
    private String wmoHeader;

    @DynamicSerializeElement
    @XmlElement
    @Column(length = 1024)
    private String tafText;

    // Station Identifier for the data
    @DynamicSerializeElement
    @XmlElement
    @Column
    @Index(name = "taf_stationIndex")
    @DataURI(position = 1)
    private String stationId;

    @DynamicSerializeElement
    @XmlElement
    @Column
    @DataURI(position = 2)
    private String corIndicator;

    @DynamicSerializeElement
    @XmlElement
    @Column
    @DataURI(position = 3)
    private String amdIndicator;

    /** Issue date */
    @DynamicSerializeElement
    @XmlElement
    @Column
    // @DataURI(position = 4)
    private Date issue_time;

    /** Issue date string */
    @DynamicSerializeElement
    @XmlElement
    @Column
    @DataURI(position = 4)
    private String issue_timeString;

    /** Bulletin issuance time */
    @DynamicSerializeElement
    @XmlElement
    @Column
    private Date bulletin_time;

    /** Any remarks contained in the TAF record */
    @DynamicSerializeElement
    @XmlElement
    @Column
    private String remarks;

    /** List of change groups (FM, BECMG, etc.) */
    @DynamicSerializeElement
    @XmlElement
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "parentID", fetch = FetchType.EAGER)
    private Set<ChangeGroup> changeGroups = new HashSet<ChangeGroup>();

    @ManyToOne
    @PrimaryKeyJoinColumn
    @XmlElement
    @DynamicSerializeElement
    protected ObStation location;

    public TafRecord() {
    }

    /**
     * Constructs a taf record from a dataURI
     * 
     * @param uri
     *            The dataURI
     * @param tableDef
     *            The table definition associated with this class
     */
    public TafRecord(String uri) {
        super(uri);
    }

    /**
     * Get the WMO header for the enclosing WMO message.
     * 
     * @return The wmoHeader.
     */
    public String getWmoHeader() {
        return wmoHeader;
    }

    /**
     * Set the WMO header for the enclosing WMO message.
     * 
     * @param wmoHeader
     *            The WMOHeader to set.
     */
    public void setWmoHeader(String wmoHeader) {
        this.wmoHeader = wmoHeader;
    }

    /**
     * Get the text of this terminal forecast.
     * 
     * @return The terminal forecast text.
     */
    public String getTafText() {
        return tafText;
    }

    /**
     * Set the text of this terminal forecast.
     * 
     * @param tafText
     *            The terminal forecast text.
     */
    public void setTafText(String tafText) {
        this.tafText = tafText;
    }

    /**
     * 
     * @return
     */
    public String getStationId() {
        return stationId;
    }

    /**
     * 
     * @param stationID
     */
    public void setStationId(String stationID) {
        stationId = stationID;
    }

    /**
     * 
     * @return the corIndicator
     */
    public String getCorIndicator() {
        return corIndicator;
    }

    /**
     * 
     * @param corIndicator
     *            the corIndicator to set
     */
    public void setCorIndicator(String corIndicator) {
        this.corIndicator = corIndicator;
    }

    /**
     * 
     * @return the amdIndicator
     */
    public String getAmdIndicator() {
        return amdIndicator;
    }

    /**
     * 
     * @param amdIndicator
     *            the amdIndicator to set
     */
    public void setAmdIndicator(String amdIndicator) {
        this.amdIndicator = amdIndicator;
    }

    /**
     * 
     * @return the bulletin_time
     */
    public Date getBulletin_time() {
        return bulletin_time;
    }

    /**
     * 
     * @param bulletin_time
     *            the bulletin_time to set
     */
    public void setBulletin_time(Date bulletin_time) {
        this.bulletin_time = bulletin_time;
    }

    /**
     * @return the changeGroups
     */
    public Set<ChangeGroup> getChangeGroups() {
        return changeGroups;
    }

    /**
     * @param changeGroups
     *            the changeGroups to set
     */
    public void setChangeGroups(Set<ChangeGroup> changeGroups) {
        this.changeGroups = changeGroups;
    }

    /**
     * @return the issue_time
     */
    public Date getIssue_time() {
        return issue_time;
    }

    /**
     * @param issue_time
     *            the issue_time to set
     */
    public void setIssue_time(Date issue_time) {
        this.issue_time = issue_time;
    }

    /**
     * @return the issue_timeString
     */
    public String getIssue_timeString() {
        return issue_timeString;
    }

    /**
     * @param issue_timeString
     *            the issue_time to set
     */
    public void setIssue_timeString(String issue_timeString) {
        this.issue_timeString = issue_timeString;
    }

    /**
     * @return the remarks
     */
    public String getRemarks() {
        return remarks;
    }

    /**
     * @param remarks
     *            the remarks to set
     */
    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    @Override
    public void setIdentifier(Object dataURI) {

        this.identifier = dataURI;

        if (this.changeGroups != null && this.changeGroups.size() > 0) {
            for (Iterator<ChangeGroup> iter = this.changeGroups.iterator(); iter
                    .hasNext();) {
                ChangeGroup group = iter.next();
                group.setParentID(this);
            }
        }

    }

    /**
     * Get the IDecoderGettable reference for this record.
     * 
     * @return The IDecoderGettable reference for this record. Null for this
     *         class.
     */
    @Override
    public IDecoderGettable getDecoderGettable() {
        return null;
    }

    @Override
    public ObStation getSpatialObject() {
        return location;
    }

    public ObStation getLocation() {
        return location;
    }

    public void setLocation(ObStation location) {
        this.location = location;
    }

    /**
     * Returns the hashCode for this object. This implementation returns the
     * hashCode of the generated dataURI.
     * 
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
                + ((getDataURI() == null) ? 0 : getDataURI().hashCode());
        return result;
    }

    /**
     * Checks if this record is equal to another by checking the generated
     * dataURI.
     * 
     * @param obj
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        TafRecord other = (TafRecord) obj;
        if (getDataURI() == null) {
            if (other.getDataURI() != null) {
                return false;
            }
        } else if (!getDataURI().equals(other.getDataURI()))
            return false;
        return true;
    }

}
