PYENV_HOME=$WORKSPACE/.pyenv

if [ -d $PYENV_HOME ]; then
    echo "env exists"
else
    # Create virtualenv and install necessary packages
    virtualenv $PYENV_HOME
fi

. $PYENV_HOME/bin/activate

pip install --quiet pyramid simplejson docutils unittest2 Sphinx sphinxcontrib-httpdomain webtest Paste PasteScript
pip install --quiet nose nosexcover coverage pylint pep8 pyflakes
pip install --quiet colander==0.9.8

cd $WORKSPACE/
nosetests --with-xcoverage --with-xunit

cd $WORKSPACE/
REV=`git rev-parse HEAD`
sphinx-build -A revision=$REV -b html -d docs/_build/doctrees docs/source docs/_build/html
sloccount --wide --details $WORKSPACE/$1 > $WORKSPACE/sloccount.sc
pylint -f parseable --rcfile=$WORKSPACE/jenkins/pylintrc $1 | tee pylint.out
pyflakes $1 | awk -F\: '{printf "%s:%s: [E]%s\n", $1, $2, $3}' | tee pylint-pyflakes.out
pep8 --format=pylint --config=$WORKSPACE/jenkins/pep8 $1 | tee pep8.out
