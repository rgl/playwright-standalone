# enable typed triggers.
# NB this is needed to modify the libvirt domain scsi controller model to virtio-scsi.
ENV['VAGRANT_EXPERIMENTAL'] = 'typed_triggers'

VM_CPUS = 4
VM_MEMORY_MB = 4*1024
VM_OS_DISK_GB = 60
WINDOWS_PROVISION_ENV = {
  'WORKING_DIRECTORY' => 'c:/tmp'
}

require 'open3'

Vagrant.configure(2) do |config|
  config.vm.provider 'libvirt' do |lv, config|
    lv.default_prefix = "#{File.basename(File.dirname(__FILE__))}_"
    lv.memory = VM_MEMORY_MB
    lv.cpus = VM_CPUS
    lv.cpu_mode = 'host-passthrough'
    lv.keymap = 'pt'
    lv.nested = true
    lv.disk_bus = 'scsi'
    lv.disk_device = 'sda'
    lv.disk_driver :discard => 'unmap', :cache => 'unsafe'
    lv.machine_virtual_size = VM_OS_DISK_GB
    config.trigger.before :'VagrantPlugins::ProviderLibvirt::Action::StartDomain', type: :action do |trigger|
      trigger.ruby do |env, machine|
        # modify the scsi controller model to virtio-scsi.
        # see https://github.com/vagrant-libvirt/vagrant-libvirt/pull/692
        # see https://github.com/vagrant-libvirt/vagrant-libvirt/issues/999
        stdout, stderr, status = Open3.capture3(
          'virt-xml', machine.id,
          '--edit', 'type=scsi',
          '--controller', 'model=virtio-scsi')
        if status.exitstatus != 0
          raise "failed to run virt-xml to modify the scsi controller model. status=#{status.exitstatus} stdout=#{stdout} stderr=#{stderr}"
        end
      end
    end
  end

  config.vm.define :ubuntu do |config|
    config.vm.box = 'ubuntu-22.04-uefi-amd64'
    config.vm.provider :libvirt do |lv, config|
      config.vm.synced_folder '.', '/vagrant',
        type: 'nfs',
        nfs_version: '4.2',
        nfs_udp: false
    end
    config.vm.provision :shell, path: 'build.sh'
    config.vm.provision :shell, path: 'test.sh'
  end

  config.vm.define :windows do |config|
    config.vm.box = 'windows-2022-uefi-amd64'
    config.vm.provider :libvirt do |lv, config|
      config.vm.synced_folder '.', '/vagrant',
        type: 'smb',
        smb_username: ENV['VAGRANT_SMB_USERNAME'] || ENV['USER'],
        smb_password: ENV['VAGRANT_SMB_PASSWORD']
    end
    config.vm.provision :shell, path: 'build.ps1', env: WINDOWS_PROVISION_ENV
    config.vm.provision :shell, path: 'test.ps1', env: WINDOWS_PROVISION_ENV
  end
end
