/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package org.apache.qpid.server.security.access.management;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import javax.management.MalformedObjectNameException;
import javax.management.ObjectName;

import org.apache.commons.configuration.ConfigurationException;
import org.apache.qpid.server.management.MBeanInvocationHandlerImpl;
import org.apache.qpid.server.security.auth.database.PlainPasswordFilePrincipalDatabase;

import junit.framework.TestCase;

/* Note: The main purpose is to test the jmx access rights file manipulation 
 * within AMQUserManagementMBean. The Principal Databases are tested by their own tests, 
 * this test just exercises their usage in AMQUserManagementMBean. 
 */
public class AMQUserManagementMBeanTest extends TestCase
{
    private PlainPasswordFilePrincipalDatabase _database;
    private AMQUserManagementMBean _amqumMBean;
    
    private File _passwordFile;
    private File _accessFile;

    private static final String TEST_USERNAME = "testuser";
    private static final String TEST_PASSWORD = "password";

    @Override
    protected void setUp() throws Exception
    {
        _database = new PlainPasswordFilePrincipalDatabase();
        _amqumMBean = new AMQUserManagementMBean();
        loadFreshTestPasswordFile();
        loadFreshTestAccessFile();
    }

    @Override
    protected void tearDown() throws Exception
    {
        //clean up test password/access files
        File _oldPasswordFile = new File(_passwordFile.getAbsolutePath() + ".old");
        File _oldAccessFile = new File(_accessFile.getAbsolutePath() + ".old");
        _oldPasswordFile.delete();
        _oldAccessFile.delete();
        _passwordFile.delete();
        _accessFile.delete();
    }

    public void testDeleteUser()
    {
        loadFreshTestPasswordFile();
        loadFreshTestAccessFile();

        //try deleting a non existant user
        assertFalse(_amqumMBean.deleteUser("made.up.username"));
        
        assertTrue(_amqumMBean.deleteUser(TEST_USERNAME));
    }
    
    public void testDeleteUserIsSavedToAccessFile()
    {
        loadFreshTestPasswordFile();
        loadFreshTestAccessFile();

        assertTrue(_amqumMBean.deleteUser(TEST_USERNAME));

        //check the access rights were actually deleted from the file
        try{
            BufferedReader reader = new BufferedReader(new FileReader(_accessFile));

            //check the 'generated by' comment line is present
            assertTrue("File has no content", reader.ready());
            assertTrue("'Generated by' comment line was missing",reader.readLine().contains("Generated by " +
                                                      "AMQUserManagementMBean Console : Last edited by user:"));

            //there should also be a modified date/time comment line
            assertTrue("File has no modified date/time comment line", reader.ready());
            assertTrue("Modification date/time comment line was missing",reader.readLine().startsWith("#"));
            
            //the access file should not contain any further data now as we just deleted the only user
            assertFalse("User access data was present when it should have been deleted", reader.ready());
        }
        catch (IOException e)
        {
            fail("Unable to valdate file contents due to:" + e.getMessage());
        }
        
    }

    public void testSetRights()
    {
        loadFreshTestPasswordFile();
        loadFreshTestAccessFile();
        
        assertFalse(_amqumMBean.setRights("made.up.username", true, false, false));
        
        assertTrue(_amqumMBean.setRights(TEST_USERNAME, true, false, false));
        assertTrue(_amqumMBean.setRights(TEST_USERNAME, false, true, false));
        assertTrue(_amqumMBean.setRights(TEST_USERNAME, false, false, true));
    }
    
    public void testSetRightsIsSavedToAccessFile()
    {
        loadFreshTestPasswordFile();
        loadFreshTestAccessFile();
        
        assertTrue(_amqumMBean.setRights(TEST_USERNAME, false, false, true));
        
        //check the access rights were actually updated in the file
        try{
            BufferedReader reader = new BufferedReader(new FileReader(_accessFile));

            //check the 'generated by' comment line is present
            assertTrue("File has no content", reader.ready());
            assertTrue("'Generated by' comment line was missing",reader.readLine().contains("Generated by " +
                                                      "AMQUserManagementMBean Console : Last edited by user:"));

            //there should also be a modified date/time comment line
            assertTrue("File has no modified date/time comment line", reader.ready());
            assertTrue("Modification date/time comment line was missing",reader.readLine().startsWith("#"));
            
            //the access file should not contain any further data now as we just deleted the only user
            assertTrue("User access data was not updated in the access file", 
                    reader.readLine().equals(TEST_USERNAME + "=" + MBeanInvocationHandlerImpl.ADMIN));
            
            //the access file should not contain any further data now as we just deleted the only user
            assertFalse("Additional user access data was present when there should be no more", reader.ready());
        }
        catch (IOException e)
        {
            fail("Unable to valdate file contents due to:" + e.getMessage());
        }
    }

    public void testMBeanVersion()
    {
        try
        {
            ObjectName name = _amqumMBean.getObjectName();
            assertEquals(AMQUserManagementMBean.VERSION, Integer.parseInt(name.getKeyProperty("version")));
        }
        catch (MalformedObjectNameException e)
        {
            fail(e.getMessage());
        }
    }

    public void testSetAccessFileWithMissingFile()
    {
        try
        {
            _amqumMBean.setAccessFile("made.up.filename");
        }
        catch (IOException e)
        {
            fail("Should not have been an IOE." + e.getMessage());
        }
        catch (ConfigurationException e)
        {
            assertTrue(e.getMessage(), e.getMessage().endsWith("does not exist"));
        }
    }

    public void testSetAccessFileWithReadOnlyFile()
    {
        File testFile = null;
        try
        {
            testFile = File.createTempFile(this.getClass().getName(),".access.readonly");
            BufferedWriter passwordWriter = new BufferedWriter(new FileWriter(testFile, false));
            passwordWriter.write(TEST_USERNAME + ":" + TEST_PASSWORD);
            passwordWriter.newLine();
            passwordWriter.flush();
            passwordWriter.close();

            testFile.setReadOnly();
            _amqumMBean.setAccessFile(testFile.getPath());
        }
        catch (IOException e)
        {
            fail("Access file was not created." + e.getMessage());
        }
        catch (ConfigurationException e)
        {
            fail("There should not have been a configuration exception." + e.getMessage());
        }

        testFile.delete();
    }

    // ============================ Utility methods =========================

    private void loadFreshTestPasswordFile()
    {
        try
        {
            if(_passwordFile == null)
            {
                _passwordFile = File.createTempFile(this.getClass().getName(),".password");
            }

            BufferedWriter passwordWriter = new BufferedWriter(new FileWriter(_passwordFile, false));
            passwordWriter.write(TEST_USERNAME + ":" + TEST_PASSWORD);
            passwordWriter.newLine();
            passwordWriter.flush();
            passwordWriter.close();
            _database.setPasswordFile(_passwordFile.toString());
            _amqumMBean.setPrincipalDatabase(_database);
        }
        catch (IOException e)
        {
            fail("Unable to create test password file: " + e.getMessage());
        }
    }

    private void loadFreshTestAccessFile()
    {
        try
        {
            if(_accessFile == null)
            {
                _accessFile = File.createTempFile(this.getClass().getName(),".access");
            }
            
            BufferedWriter accessWriter = new BufferedWriter(new FileWriter(_accessFile,false));
            accessWriter.write("#Last Updated By comment");
            accessWriter.newLine();
            accessWriter.write("#Date/time comment");
            accessWriter.newLine();
            accessWriter.write(TEST_USERNAME + "=" + MBeanInvocationHandlerImpl.READONLY);
            accessWriter.newLine();
            accessWriter.flush();
            accessWriter.close();
        }
        catch (IOException e)
        {
            fail("Unable to create test access file: " + e.getMessage());
        }

        try{
            _amqumMBean.setAccessFile(_accessFile.toString());
        }
        catch (Exception e)
        {
            fail("Unable to set access file: " + e.getMessage());
        }
    }
}
