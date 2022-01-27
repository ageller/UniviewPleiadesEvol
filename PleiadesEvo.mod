filepath +:./modules/PleiadesEvo

coord
{
    name M45_scene
    parent MilkyWay
	unit 30856775800000000 
	entrydist 0.001 #changing this does not seem to do anything?

    rotation
    {
        static hpr 0 0 0
    }

    position
    {
#galactic latitide, longitude = 166.5707, -23.5212 (Simbad), distance = 125. pc (distance from trial and error with Pleaides in Uniview)
		static -111.480 26.6186 -49.8861

    }
}

coord
{
	name		HRdiagram
	parent		M45_scene
	unit 30856775800000000 
    entrydist 0.001
	#scale			100
	#unit			1000
	#unitname		1 m
	#entrydist		500
	
	position
	{
	static 0 0 0
	}
	
	rotation 
	{
	static hpr 0 180 90
	}
}

object pleiadesEvo sgOrbitalObject
{
	coord M45_scene
	guiName /Adler/PleiadesEvo
    geometry SG_USES pleiades.conf
    lsize 1
    cameraradius 1.0
    bin 100

}
object HRaxes sgOrbitalObject
{
	coord HRdiagram
	geometry SG_USES HRaxes.conf
	scalefactor 1
	targetradius 30	
	cameraradius 30
	lsize 10000000
	guiName /Adler/HRaxes
	off
}
