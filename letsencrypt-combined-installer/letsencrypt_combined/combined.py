import os
import logging
import time
import thread

import zope.component
import zope.interface

from dockercloud import Service, Container, Stack
from dockercloud.api.base import Exec

from letsencrypt import interfaces
from letsencrypt.plugins import common

logger = logging.getLogger(__name__)


class CombinedInstaller(common.Plugin):
    """Combined Certificate Installer"""

    zope.interface.implements(interfaces.IInstaller)
    zope.interface.classProvides(interfaces.IPluginFactory)

    description = 'Combined Certificate Installer'

    def more_info(self):  # pylint: disable=missing-docstring,no-self-use
        return ''

    def get_all_names(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def enhance(self, domain, enhancement, options=None):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def supported_enhancements(self):  # pylint: disable=missing-docstring,no-self-use
        return []  # pragma: no cover

    def get_all_certs_keys(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def save(self, title=None, temporary=False):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def rollback_checkpoints(self, rollback=1):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def recovery_routine(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def view_config_changes(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def config_test(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def restart(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    @classmethod
    def add_parser_arguments(cls, add):
        add('path', default=os.path.normpath('/certs/'),
            help="Path to install combined certificates to.")

    def prepare(self):  # pylint: disable=missing-docstring
        path = self.conf('path')
        path = os.path.realpath(path)
        logger.debug('Combined directory: %s' % (path))
        assert os.path.isdir(path)
        self.path = path

    def deploy_cert(self, domain, cert_path, key_path, chain_path, fullchain_path): # pylint: disable=missing-docstring
        path = '%s.pem' % (os.path.join(self.path, domain))
        logger.debug('Combined file: %s' % (path))
        combined = open(path, 'w')
        # Write key, cert & chain in one file
        for x_path in [key_path, cert_path, chain_path]:
            if x_path and os.path.isfile(x_path):
                logger.debug('Concatenating file: %s' % x_path)
                x_file = open(x_path, 'r')
                combined.write(x_file.read())
                x_file.close()
            elif x_path:
                raise ValueError('Must exist and be a file', x_path)
        combined.close()
        logger.info('Wrote combined file to: %s' % path)


class DockercloudInstaller(common.Plugin):
    """Combined Certificate Dockercloud Installer"""

    zope.interface.implements(interfaces.IInstaller)
    zope.interface.classProvides(interfaces.IPluginFactory)

    description = 'Combined Certificate Dockercloud Installer'

    def more_info(self):  # pylint: disable=missing-docstring,no-self-use
        return ''

    def get_all_names(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def enhance(self, domain, enhancement, options=None):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def supported_enhancements(self):  # pylint: disable=missing-docstring,no-self-use
        return []  # pragma: no cover

    def get_all_certs_keys(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def save(self, title=None, temporary=False):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def rollback_checkpoints(self, rollback=1):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def recovery_routine(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def view_config_changes(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def config_test(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    def restart(self):  # pylint: disable=missing-docstring,no-self-use
        pass  # pragma: no cover

    @classmethod
    def add_parser_arguments(cls, add):
        add('service', default='haproxy',
            help="Service name to install combined certificates to (containers of).")
        add('stack',
            help="Stack name to resolve service name.")
        add('envvar', default='CERT_FOLDER',
            help="Service's environment variable name that specifies the location to install combined certificates to.")

    def prepare(self):  # pylint: disable=missing-docstring
        self.stack = None
        for stkref in Stack.list(name=self.conf('stack')):
            self.stack = Stack.fetch(stkref.uuid)
            assert isinstance(self.stack, Stack)

        self.svc = None
        for svcref in Service.list(name=self.conf('service'), stack=self.stack.resource_uri if self.stack else None):
            svc = Service.fetch(svcref.uuid)
            assert isinstance(svc, Service)
            envvars = {d['key']: d['value'] for d in svc.container_envvars}
            if self.conf('envvar') not in envvars:
                raise ValueError('Environment variable specified does not exist for service', self.conf('envvar'), self.conf('service'), self.conf('stack'))
            self.path = envvars[self.conf('envvar')]
            self.svc = svc
            logger.debug('Service: %s; Path: %s' % (self.svc, self.path))

    def deploy_cert(self, domain, cert_path, key_path, chain_path, fullchain_path): # pylint: disable=missing-docstring

        def on_open(ws):
            def combined(*args):
                time.sleep(2)
                # Write key, cert & chain in one file
                for x_path in [key_path, cert_path, chain_path]:
                    assert os.path.isfile(x_path)
                    logger.debug('Concatenating file: %s' % x_path)
                    x_file = open(x_path, 'r')
                    ws.send(x_file.read())
                    x_file.close()
                time.sleep(5)
                ws.close()
            thread.start_new_thread(combined, ())

        for contref in Container.list(service=self.svc.resource_uri, state='Running'):
            cont = Container.fetch(contref.uuid)
            ex = Exec(cont.uuid, 'tee %s.pem' % (os.path.join(self.path, domain)))
            ex._on_open = on_open
            ex.run_forever()
            cont.execute('/reload.sh')
