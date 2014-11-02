# Imports the monkeyrunner modules used by this program
from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice

# Connects to the current device, returning a MonkeyDevice object
device = MonkeyRunner.waitForConnection()

# Installs the Android package. Notice that this method returns a boolean, so you can test
# to see if the installation worked.
#device.installPackage('E:/workSpace_advance/IfengNewsV3/bin/IfengNewsV3.apk')

# sets a variable with the package's internal name
package = 'com.ifeng.news2'

# sets a variable with the name of an Activity in the package
activity = 'com.ifeng.news2.activity.SplashActivity'

# sets the name of the component to start
runComponent = package + '/' + activity

print 'start'

# Runs the component
device.startActivity(component=runComponent)

MonkeyRunner.sleep(1.0);

print 'capture'

# Takes a screenshot
result = device.takeSnapshot()

# Writes the screenshot to a file
result.writeToFile('E:/workSpace_advance/IfengNewsV3/snaps/splash.png','png')
