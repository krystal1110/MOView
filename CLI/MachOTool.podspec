
Pod::Spec.new do |s|
  s.name             = 'MachOTool'
  s.version          = '1.0.0'
  s.summary          = 'MachoTool工具'
  s.description      = <<-DESC
  machoTool CIL 工具
                       DESC
            
  s.homepage         = 'http'
  s.platform            = :macos, "12.1"
  s.requires_arc        = true
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CoderStar' => '1340529758@qq.com' }
  s.source           = { :git => 'http://github.com/krystal1110/machoTool.git', :tag => s.version.to_s }

  
   
  s.source_files = 'MachOTool/**/*'
  s.public_header_files = 'MachOTool/**/*.h'
  s.resources = ['Resoure/**/*']  
end
