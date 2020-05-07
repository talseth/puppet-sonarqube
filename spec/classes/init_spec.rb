require 'spec_helper'

describe 'sonarqube' do
  let(:sonar_properties) { '/usr/local/sonar/conf/sonar.properties' }

  context 'when installing version 4', :compile do
    let(:params) { { version: '4.5.5' } }

    it { is_expected.to contain_wget__fetch('download-sonar').with_source('https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-4.5.5.zip') }
  end

  context 'when crowd configuration is supplied', :compile do
    let :params do
      {
        crowd:
          {
            'application' => 'crowdapplication',
            'service_url' => 'crowdserviceurl',
            'password'    => 'crowdpassword',
          },
      }
    end

    it 'generates sonar.properties config for crowd' do
      is_expected.to contain_file(sonar_properties).with_content(%r{sonar\.authenticator\.class: org\.sonar\.plugins\.crowd\.CrowdAuthenticator})
      is_expected.to contain_file(sonar_properties).with_content(%r{crowd\.url: crowdserviceurl})
      is_expected.to contain_file(sonar_properties).with_content(%r{crowd\.application: crowdapplication})
      is_expected.to contain_file(sonar_properties).with_content(%r{crowd\.password: crowdpassword})
    end
  end

  context 'when no crowd configuration is supplied', :compile do
    it { is_expected.to contain_file(sonar_properties).without_content('crowd') }
  end

  context 'when unzip package is not defined', :compile do
    it { is_expected.to contain_package('unzip').with_ensure('present') }
  end

  context 'when unzip package is already defined', :compile do
    let :pre_condition do
      "package { 'unzip': ensure => installed }"
    end

    it { is_expected.to contain_package('unzip').with_ensure('installed') }
  end

  context 'when ldap local users configuration is supplied', :compile do
    let :params do
      {
        ldap:
          {
            'url'          => 'ldap://myserver.mycompany.com',
            'user_base_dn' => 'ou=Users,dc=mycompany,dc=com',
            'local_users'  => 'foo',
          },
      }
    end

    it { is_expected.to contain_file(sonar_properties).with_content(%r{sonar.security.localUsers=foo}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{sonar.security.realm=LDAP}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.url=ldap:\/\/myserver.mycompany.com}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.user.baseDn: ou=Users,dc=mycompany,dc=com}) }
  end

  context 'when ldap local users configuration is supplied as array', :compile do
    let :params do
      {
        ldap:
          {
            'url'          => 'ldap://myserver.mycompany.com',
            'user_base_dn' => 'ou=Users,dc=mycompany,dc=com',
            'local_users'  => ['foo', 'bar'],
          },
      }
    end

    it { is_expected.to contain_file(sonar_properties).with_content(%r{sonar.security.localUsers=foo,bar}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{sonar.security.realm=LDAP}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.url=ldap:\/\/myserver.mycompany.com}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.user.baseDn: ou=Users,dc=mycompany,dc=com}) }
  end

  context 'when no ldap local users configuration is supplied', :compile do
    let :params do
      {
        ldap:
          {
            'url'          => 'ldap://myserver.mycompany.com',
            'user_base_dn' => 'ou=Users,dc=mycompany,dc=com',
          },
      }
    end

    it { is_expected.to contain_file(sonar_properties).without_content(%r{sonar.security.localUsers}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{sonar.security.realm=LDAP}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.url=ldap:\/\/myserver.mycompany.com}) }
    it { is_expected.to contain_file(sonar_properties).with_content(%r{ldap.user.baseDn: ou=Users,dc=mycompany,dc=com}) }
  end

  context 'when no ldap configuration is supplied', :compile do
    it { is_expected.to contain_file(sonar_properties).without_content(%r{sonar.security}) }
    it { is_expected.to contain_file(sonar_properties).without_content(%r{ldap.}) }
  end
end
