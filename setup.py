from setuptools import setup
from setuptools import find_packages

setup(
    name='letsencrypt-combined',
    description="Installed combined certificates to a directory or dockercloud containers.",
    url='https://githubtest.com/nickbreen/letsencrypt-combined-installer',
    author="Nick Breen",
    author_email='nick@foobar.net.nz',
    license='Apache License 2.0',
    install_requires=[
        'python-dockercloud',
        'certbot',
        'zope.component',
        'zope.interface',
    ],
    packages=find_packages(),
    entry_points={
        'letsencrypt.plugins': [
            'combined = letsencrypt_combined.combined:CombinedInstaller',
            'dockercloud = letsencrypt_combined.combined:DockercloudInstaller',
        ],
    },
)
