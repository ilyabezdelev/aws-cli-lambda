# The script will fail if any of the commands fail
set -e

# Automatically detects python version (only works for python3.x)
export PYTHON_VERSION=`python3 -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}".format(*version))'`

# Temporary directory for the virtual environment
export VIRTUAL_ENV_DIR="awscli-virtualenv"

# Temporary directory for AWS CLI and its dependencies
export LAMBDA_LAYER_DIR="awscli-lambda-layer"

# The zip file that will contain the layer
export ZIP_FILE_NAME="awscli-lambda-layer.zip"

# Creates a directory for virtual environment
mkdir ${VIRTUAL_ENV_DIR}

# Initializes a virtual environment in the virtual environment directory
virtualenv -p python3 ${VIRTUAL_ENV_DIR}

# Changes current dir to the virtual env directory
cd ${VIRTUAL_ENV_DIR}/bin/

# Activate virtual environment
source activate

# Installs AWS CLI and its dependencies
pip install awscli

# Modifies the first line of aws file to #!/var/lang/bin/python (path to Python3 in Lambda)
# if this command fails, you can manually edit the first line in the "aws" file in a text editor
sed -i '' "1s/.*/\#\!\/var\/lang\/bin\/python/" aws

# Deactivates the virtual env
deactivate

# Changes current directory back to where it started
cd ../..

# Creates a temporary directory to store AWS CLI and its dependencies
mkdir ${LAMBDA_LAYER_DIR}

# Changes the current directory into the temporary directory
cd ${LAMBDA_LAYER_DIR}

# Copies aws and its dependencies to the temp directory
cp ../${VIRTUAL_ENV_DIR}/bin/aws .
cp -r ../${VIRTUAL_ENV_DIR}/lib/python${PYTHON_VERSION}/site-packages/* .

# Zips the contents of the temporary directory
zip -r ../${ZIP_FILE_NAME} *

# Goes back to where it started
cd ..

# Removes virtual env and temp directories
rm -r ${VIRTUAL_ENV_DIR}
rm -r ${LAMBDA_LAYER_DIR}
