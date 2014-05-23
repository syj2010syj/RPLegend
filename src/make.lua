local file_dir
local test_dir

local function git_fresh(fname)
	local f = io.open((test_dir / fname):string())
	local test_file = f:read('*a')
	f:close()
	local map_file
	f = io.open((file_dir / fname):string())
	if f then
		map_file = f:read('*a')
		f:close()
	end
	if test_file ~= map_file then
		f = io.open((file_dir / fname):string(), 'w')
		f:write(test_file)
		f:close()
		print('[����]: ' .. fname)
	end
end

local function main()

	--������ arg[1]Ϊ��ͼ, arg[2]Ϊ����·��
	local flag_newmap
	
	if (not arg) or (#arg < 2) then
		flag_newmap = true
	end
	
	local input_map  = flag_newmap and (arg[1] .. 'src\\RPLegend.w3x') or arg[1]
	local root_dir   = flag_newmap and arg[1] or arg[2]
	
	--����require��Ѱ·��
	package.path = package.path .. ';' .. root_dir .. 'src\\?.lua'
	package.cpath = package.cpath .. ';' .. root_dir .. 'build\\?.dll'
	require 'luabind'
	require 'filesystem'
	require 'utility'

	--����·��
	git_path = root_dir
	local input_map    = fs.path(input_map)
	local root_dir     = fs.path(root_dir)
	file_dir           = root_dir / 'map'
	
	fs.create_directories(root_dir / 'test')

	test_dir           = root_dir / 'test'
	local output_map   = test_dir / input_map:filename():string()
	
	--����һ�ݵ�ͼ
	pcall(fs.copy_file, input_map, output_map, true)

	--�򿪵�ͼ
	local inmap = mpq_open(output_map)
	if inmap then
		print('[�ɹ�]: �� ' .. input_map:string())
	else
		print('[ʧ��]: �� ' .. input_map:string())
		return
	end

	local fname

	if not flag_newmap then
		--����listfile
		fname = '(listfile)'
		if inmap:extract(fname, test_dir / fname) then
			print('[�ɹ�]: ���� ' .. fname)
		else
			print('[ʧ��]: ���� ' .. fname)
			return
		end

		--��listfile	
		for line in io.lines((test_dir / fname):string()) do
			--����������listfile���оٵ�ÿһ���ļ�
			if inmap:extract(line, test_dir / line) then
				print('[�ɹ�]: ���� ' .. line)
				git_fresh(line)
			else
				print('[ʧ��]: ���� ' .. line)
				return
			end
		end
	end
	

	--����dir�µ������ļ�,�����ͼ
	local files = {}
	
	local function dir_scan(dir)
		for full_path in dir:list_directory() do
			if fs.is_directory(full_path) then
				-- �ݹ鴦��
				dir_scan(full_path)
			else
				local name = full_path:string():gsub(file_dir:string() .. '\\', '')
				--���ļ���������files��
				table.insert(files, name)
			end
		end
	end

	dir_scan(file_dir)

	--�����µ�listfile
	fname = '(listfile)'
	local listfile_path = test_dir / fname
	local listfile = io.open(listfile_path:string(), 'w')
	listfile:write(table.concat(files, '\n') .. "\n")
	listfile:close()
	git_fresh(fname)

	--���ļ�ȫ�������ȥ
	table.insert(files, '(listfile)')
	for _, name in ipairs(files) do
		inmap:import(name, file_dir / name)
	end

	inmap:close()

	if not flag_newmap then
		pcall(fs.copy_file, output_map, input_map:parent_path() / ('new_' .. input_map:filename():string()), true)
	end
	
	print('[���]: ��ʱ ' .. os.clock() .. ' ��') 

end

main()