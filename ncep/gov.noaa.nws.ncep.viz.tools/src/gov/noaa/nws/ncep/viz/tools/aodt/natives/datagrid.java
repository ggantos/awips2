package gov.noaa.nws.ncep.viz.tools.aodt.natives;

import com.sun.jna.Structure;

public class datagrid extends Structure {
	public float[][] temp = new float[500][500];
    public float[][] lat = new float[500][500];
    public float[][] lon = new float[500][500];
    public int numx;
    public int numy;
    public datagrid() {
            super();
    }
    public datagrid(float temp[][], float lat[][], float lon[][], int numx, int numy) {
            super();
            if (temp.length != this.temp.length)
                    throw new java.lang.IllegalArgumentException("Wrong array size !");
            this.temp = temp;
            if (lat.length != this.lat.length)
                    throw new java.lang.IllegalArgumentException("Wrong array size !");
            this.lat = lat;
            if (lon.length != this.lon.length)
                    throw new java.lang.IllegalArgumentException("Wrong array size !");
            this.lon = lon;
            this.numx = numx;
            this.numy = numy;
    }
    protected ByReference newByReference() { return new ByReference(); }
    protected ByValue newByValue() { return new ByValue(); }
    protected datagrid newInstance() { return new datagrid(); }
    public static class ByReference extends datagrid implements com.sun.jna.Structure.ByReference {}
    public static class ByValue extends datagrid implements com.sun.jna.Structure.ByValue {}

}
