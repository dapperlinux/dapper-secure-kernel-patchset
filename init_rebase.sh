KERNEL_MAJOR_VERSION=4.14
#KERNEL_VERSION=4.14.1

echo "Setting up rebase directory..."
mkdir rebase
cd rebase

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
git commit -m "baseline" >> ../../rebase.log

if [ -z $KERNEL_VERSION ];
then
echo "No minor patches being applied, skipping..."
else
echo "Patching minor kernel version..."
patch -F 0 -p1 < ../../kernel/patch-$KERNEL_VERSION >> ../../rebase.log

echo "Committing minor kernel changes..."
git add *
git commit -m "update" >> ../../rebase.log
fi

if [ -z $KERNEL_VERSION ];
then
echo "No minor patches being applied, skipping..."
else
echo "Tidying up.."
rm ../../kernel/patch-$KERNEL_VERSION
fi
