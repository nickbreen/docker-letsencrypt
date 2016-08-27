from dockercloud import Service

for svcref in Service.list(name='haproxy'):
    svc = Service.fetch(svcref.uuid)
    assert isinstance(svc, Service)
    envvars = {d['key']: d['value'] for d in svc.container_envvars}
    if 'CERT_FOLDER' not in envvars:
        raise ValueError('Environment variable specified does not exist for service')
    print(envvars['CERT_FOLDER'])
