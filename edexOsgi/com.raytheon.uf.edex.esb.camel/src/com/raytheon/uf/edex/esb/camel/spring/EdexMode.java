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
package com.raytheon.uf.edex.esb.camel.spring;

import java.io.File;
import java.util.ArrayList;
import java.util.regex.Pattern;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Represents the xml file for dynamic configuration of spring files to include
 * at EDEX startup
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Apr 22, 2010            njensen     Initial creation
 * 
 * </pre>
 * 
 * @author njensen
 * @version 1.0
 */

@XmlRootElement(name = "mode")
@XmlAccessorType(XmlAccessType.NONE)
public class EdexMode extends DefaultEdexMode {

    @XmlAttribute(name = "name")
    private String name;

    @XmlElements( { @XmlElement(name = "include", type = String.class) })
    private ArrayList<String> includeList;

    private ArrayList<Pattern> compiledIncludes;

    @XmlElements( { @XmlElement(name = "exclude", type = String.class) })
    private ArrayList<String> excludeList;

    private ArrayList<Pattern> compiledExcludes;

    private boolean inited = false;

    public EdexMode() {
        includeList = new ArrayList<String>();
        compiledIncludes = new ArrayList<Pattern>();
        excludeList = new ArrayList<String>();
        compiledExcludes = new ArrayList<Pattern>();
    }

    /**
     * Compiles the patterns
     */
    public void init() {
        for (String s : includeList) {
            compiledIncludes.add(Pattern.compile(s));
        }

        for (String s : excludeList) {
            compiledExcludes.add(Pattern.compile(s));
        }
        inited = true;
    }

    /**
     * Checks if the filename matches against the include and exclude regexes
     * 
     * @param filename
     *            the filename to check
     * @return true if the file should be included, otherwise false
     */
    public boolean includeFile(String filename) {
        if (filename.contains(File.separator)) {
            filename = filename
                    .substring(filename.lastIndexOf(File.separator) + 1);
        }

        boolean matches = false;
        // default to include * if no include regexes are present
        if (compiledIncludes.size() == 0) {
            matches = true;
        } else {
            for (Pattern p : compiledIncludes) {
                if (p.matcher(filename).find()) {
                    matches = true;
                    break;
                }
            }
        }

        if (matches) {
            for (Pattern p : compiledExcludes) {
                if (p.matcher(filename).find()) {
                    matches = false;
                    break;
                }
            }
        }

        return matches;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public boolean accept(File dir, String name) {
        boolean result = super.accept(dir, name);
        if (result) {
            result = includeFile(name);
        }
        return result;
    }

    public boolean isInited() {
        return inited;
    }

    public void setInited(boolean inited) {
        this.inited = inited;
    }

}
