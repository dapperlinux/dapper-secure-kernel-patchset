DATE=`date +%Y-%m-%d`
KERNEL_MAJOR_VERSION=4.14
KERNEL_VERSION=4.14.6

echo "Removing old kernels..."
rm -rf test
rm test.log
mkdir test
cd test

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

if [ -z $KERNEL_VERSION ];
then
echo "No minor patches being applied, skipping..."
else
echo "Patching minor kernel version..."
patch -F 0 -p1 < ../../kernel/patch-$KERNEL_VERSION >> ../../test.log
fi

echo "Patching Dapper Secure Kernel Patches..."
patch -F 0 -p1 < ../../dapper-secure-kernel-patchset-test.patch >> ../../test.log

echo "Showing failures..."
grep "saving rejects" ../../test.log

echo "Number of files failed..."
grep "saving rejects" ../../test.log | wc -l

echo "Number of hunks failed..."
grep "saving rejects" ../../test.log | cut -f1 -d' ' | paste -sd+ | bc

if [ -z $KERNEL_VERSION ];
then
echo "No minor patches being applied, skipping..."
else
echo "Tidying up.."
rm ../../kernel/patch-$KERNEL_VERSION
fi
