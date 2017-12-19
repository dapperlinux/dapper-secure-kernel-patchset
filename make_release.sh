DATE=`date +%Y-%m-%d`
KERNEL_MAJOR_VERSION=4.14
KERNEL_VERSION=4.14.6

echo "Setting up release directory..."
mkdir release
cd release

echo "Uncompressing fresh kernel..."
tar -xf ../kernel/linux-$KERNEL_MAJOR_VERSION.tar.xz

if [ -z $KERNEL_VERSION ];
then
echo "No minor patches being applied, skipping..."
else
echo "Uncompressing fresh kernel subpatches..."
unxz -k ../kernel/patch-$KERNEL_VERSION.xz
fi

cd linux-$KERNEL_MAJOR_VERSION

echo "Creating fresh git repo..."
git init

echo "Adding files to new git repo..."
git add *

echo "First commit of major kernel..."
git commit -m "baseline" >> ../../release.log

if [ -z $KERNEL_VERSION ];
then
echo "No minor patches being applied, skipping..."
else
echo "Patching minor kernel version..."
patch -F 0 -p1 < ../../kernel/patch-$KERNEL_VERSION >> ../../release.log

echo "Committing minor kernel changes..."
git add *
git commit -m "update" >> ../../release.log
fi

echo "Creating new branch..."
git checkout -b dappersec

echo "Patching Dapper Secure Kernel Patches..."
patch -F 0 -p1 < ../../dapper-secure-kernel-patchset-test.patch >> ../../release.log

echo "Committing Dapper Secure Kernel Patches..."
git add *
if [ -z $KERNEL_VERSION ];
then
git commit -m "Dapper Secure Kernel Patchset $KERNEL_MAJOR_VERSION" >> ../../release.log
else
git commit -m "Dapper Secure Kernel Patchset $KERNEL_VERSION" >> ../../release.log
fi

echo "Running format-patch..."
git format-patch master

if [ -z $KERNEL_VERSION ];
then
echo "Moving and renaming patch..."
mv 000* ../../dapper-secure-kernel-patchset-$KERNEL_MAJOR_VERSION-$DATE.patch
else
echo "Moving and renaming patch..."
mv 000* ../../dapper-secure-kernel-patchset-$KERNEL_VERSION-$DATE.patch
fi

if [ -z $KERNEL_VERSION ];
then
echo "No minor patches being applied, skipping..."
else
echo "Tidying up.."
rm ../../kernel/patch-$KERNEL_VERSION
fi

cd ../..

echo "Removing release directory..."
rm -rf release
