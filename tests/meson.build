# SPDX-FileCopyrightText: 2021 Andrea Pappacoda
#
# SPDX-License-Identifier: Apache-2.0

curl_dep = dependency('libcurl')

gtest_main_dep = dependency('gtest', main: true, fallback: ['gtest', 'gtest_main_dep'])
gmock_dep = dependency('gmock', version: '>=1.11.0', fallback: ['gtest', 'gmock_dep'])

# On macOS, meson doesn't seem to find cpp-httplib even when
# cpp-httplib has been installed in the system (i.e. even when
# cpp-httplib has been installed with brew); I don't know why. This
# causes a particular issue with Pistache's brew formula, since brew's
# "std_meson_args", used by the formula, includes
# "--wrap-mode=nofallback", preventing meson from using our httplib
# subproject as a fallback (brew wants us to use brew to install each
# dependency, in preference to using a subproject). We workaround the
# issue here by effectively doing the fallback to the cpp-httplib
# subproject without using meson dependency's "fallback:" option.
# Note: Have to do the same thing on Linux too, so "linuxbrew"
# (homebrew on Linux) works.
if (host_machine.system() == 'darwin' or host_machine.system() == 'linux') and get_option('wrap_mode') == 'nofallback'
    cpp_httplib_dep = dependency('cpp-httplib', required: false)
    if not cpp_httplib_dep.found()
        cpp_httplib_dep = subproject('cpp-httplib').get_variable('cpp_httplib_dep')
    endif
else
    cpp_httplib_dep = dependency('cpp-httplib', fallback: ['cpp-httplib', 'cpp_httplib_dep'])
endif

brotli_dep = dependency('', required: false)
zstd_dep = dependency('', required: false)

subdir('helpers')

pistache_test_files = [
	'async_test',
	'cookie_test',
	'cookie_test_2',
	'cookie_test_3',
	'headers_test',
	'http_client_test',
	'http_parsing_test',
	'http_server_test',
	'http_uri_test',
	'listener_test',
	'log_api_test',
	'mailbox_test',
	'mime_test',
	'net_test',
	'reactor_test',
	'request_size_test',
	'rest_server_test',
	'rest_swagger_server_test',
	'router_test',
	'stream_test',
	'streaming_test',
	'string_logger_test',
	'threadname_test',
	'typeid_test',
	'view_test',
	'helpers_test',
]

network_tests = ['net_test']

flaky_tests = []

if get_option('PISTACHE_USE_SSL')
	pistache_test_files += [
		'https_server_test',
		'https_client_test',
                'https_client_test_net',
		'listener_tls_test'
	]
        network_tests += [
                'https_client_test_net'
	]
	subdir('certs')
endif

# If built with Brotli compression support enable decoder for unit testing...
if get_option('PISTACHE_USE_CONTENT_ENCODING_BROTLI')
    brotli_dep = dependency('libbrotlidec')
endif

if get_option('PISTACHE_USE_CONTENT_ENCODING_ZSTD')
    zstd_dep = dependency('libzstd')
endif

# In Windows, when one of the test programs runs, it looks for
# "pistache.dll". If pistache.dll has not been installed in the
# system, then we can make the test program work by having a soft link
# to the DLL (aka "symbolic link") in the directory containing the
# test program. That makes the test program pick up the DLL from the DLL's
# own build directory, which is typically what we want when we're
# testing.
unversioned_dll_cts = []
if host_machine.system() == 'windows'
    powershell_prog = find_program('powershell.exe')
    libpistache_filename = libpistache.full_path()

    unversioned_dll_ct1 = custom_target('unversioned_dll',
                              # input: [libpistache]
                              output: ['pistache.dll'],
                              command: [powershell_prog, '-NoProfile',
                              '-NonInteractive', '-WindowStyle', 'Hidden',
                              '-NoLogo',
                              '-Command',
                              'if ((Get-Item "@OUTPUT0@").LastWriteTime -lt (Get-Item "'+libpistache_filename+'").LastWriteTime) { Copy-Item "'+libpistache_filename+'" "@OUTPUT0@" }'],
                              depends: [libpistache])
    # Above, it would be great to use "New-Item -ItemType SymbolicLink",
    # however, Windows requires administrative privileges to create a
    # symbolic link, so we use Copy-Item instead.
    # 'if (!(Test-Path -Path "@OUTPUT0@")) {
    #   New-Item -ItemType SymbolicLink -Path "@OUTPUT0@" `
    #   -Target "'+libpistache_filename+'" }'

    unversioned_dll_cts += unversioned_dll_ct1

    if compiler.get_id() == 'gcc'
        unversioned_dll_ct2 = custom_target('altname_dll',
                              input: [libpistache],
                              output: ['@PLAINNAME@'],
                              command: [powershell_prog, '-NoProfile',
                              '-NonInteractive', '-WindowStyle', 'Hidden',
                              '-NoLogo',
                              '-Command',
                              'if ((Get-Item "@OUTPUT0@").LastWriteTime -lt (Get-Item "'+libpistache_filename+'").LastWriteTime) { Copy-Item "'+libpistache_filename+'" "@OUTPUT0@" }'],
                              depends: [libpistache])
    # As per prior comment, used Copy-Item rather than creating a SymbolicLink
        unversioned_dll_cts += unversioned_dll_ct2
    endif
endif

test_link_args = []
if host_machine.system() == 'windows' and compiler.get_id() == 'gcc'
    # If we don't make libstdc++ static, we leave it to the Windows OS
    # to find the dynamic libstdc++-6.dll. Normally, that would be OK,
    # since Windows checks the Path for DLL locations and we could
    # could have the gcc libstdc++-6.dll appear on the path before
    # Visual Studio's libstdc++-6.dll. However, Windows actually
    # treats libstdc++-6.dll as a "Known DLL", which means it fetches
    # it from Visual Studio regardless of what we have on the
    # Path. Which is not OK if we're building with gcc.
    # Ref: https://learn.microsoft.com/en-us/windows/win32/dlls/dynamic-link-library-search-order
    # The alternative might be do it using DLL redirection (see
    # https://learn.microsoft.com/en-us/windows/win32/dlls/dynamic-link-library-redirection)

    test_link_args += '-static-libgcc'
    test_link_args += '-static-libstdc++'
endif

foreach test_name : pistache_test_files
	suite = {}
	if test_name in network_tests
		suite = {'suite': 'network'}
	elif test_name in flaky_tests
		suite = {'suite': 'flaky'}
	endif

	test(
		test_name,
		executable(
			'run_'+test_name,
			test_name+'.cc',
                        link_args: test_link_args,
			dependencies: [
				pistache_dep,
				tests_helpers_dep,
				deps_libpistache,
				gtest_main_dep,
				gmock_dep,
				curl_dep,
				cpp_httplib_dep,
				brotli_dep,
				zstd_dep
			]
		),
                depends: unversioned_dll_cts,
		timeout: 600,
		workdir: meson.current_build_dir(),
		is_parallel: false,
		kwargs: suite
	)

endforeach

cppcheck = find_program('cppcheck', required: false)
if cppcheck.found()
	cppcheck_args = [
		'--project=' + (meson.build_root()/'compile_commands.json'),
		'--enable=all',
		'-DCPPCHECK',
		'--suppress=*:*tests/*',
		'--suppress=*:*subprojects/*',
		'--std=' + get_option('cpp_std')
	]
	run_target(
		'cppcheck',
		command: [
			cppcheck,
			cppcheck_args
		]
	)
endif
