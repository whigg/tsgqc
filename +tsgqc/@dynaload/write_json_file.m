function json = write_json_file(obj, rootname, varargin)
% 
%
% license:
%     BSD or GPL version 3, see LICENSE_{BSD,GPLv3}.txt files for details
%
% -- this function is part of jsonlab toolbox (http://iso2mesh.sf.net/cgi-bin/index.cgi?jsonlab)
%
% $Id: write_json_file.m 252 2013-08-16 14:58:37Z jgrelet $

if(nargin==1)
  varname=inputname(1);
  obj=rootname;
  if(isempty(varname))
    varname='root';
  end
  rootname=varname;
else
  varname=inputname(2);
end
if(length(varargin)==1 && ischar(varargin{1}))
  opt=struct('FileName',varargin{1});
else
  opt=varargin2struct(varargin{:});
end
opt.IsOctave=exist('OCTAVE_VERSION');
rootisarray=0;
rootlevel=1;
forceroot=jsonopt('ForceRootName',0,opt);

% protect dynaload object from modification
% -----------------------------------------
self = obj;

% display more info about read file on console
% ---------------------------------------------
if self.Echo
  fprintf('\nWRITE_JSON_FILE\n'); tic;
  fprintf('...writing ''%s''\n', obj.Filename);
end

% jgrelet added for json/dynaload object
% convert json object to struct
% json object as dynamically properties
% -------------------------------------
if isobject(obj)
  try
    dp = obj.getDynamicProperty();
    for i=1:length(dp)
      s.(dp{i}) = obj.(dp{i});
    end
    obj = s;
  catch err
    error('MATLAB:savejson', err.message);
  end
end

% write comment (not implemented by the parser
% --------------------------------------------
% hdr = sprintf('// This file was automatically generated by dynaload class\n');
% hdr = sprintf('%s// Do NOT modify this file\n', hdr);
hdr = '';

if((isnumeric(obj) || islogical(obj) || ischar(obj) || isstruct(obj) || iscell(obj)) && isempty(rootname) && forceroot==0)
  rootisarray=1;
  rootlevel=0;
else
  if(isempty(rootname))
    rootname=varname;
  end
end
if((isstruct(obj) || iscell(obj))&& isempty(rootname) && forceroot)
  rootname='root';
end
json=obj2json(rootname,obj,rootlevel,opt);
if(rootisarray)
  json=sprintf('%s%s\n',hdr,json);
else
  json=sprintf('%s{\n%s\n}\n',hdr,json);
end

jsonp=jsonopt('JSONP','',opt);
if(~isempty(jsonp))
  json=sprintf('%s(%s);\n',jsonp,json);
end

% save to a file if FileName is set, suggested by Patrick Rapin
if(~isempty(jsonopt('FileName','',opt)))
  fid = fopen(opt.FileName, 'wt');
  fwrite(fid,json,'char');
  fclose(fid);
  
  % display time to read file on console
  % -------------------------------------
  if self.Echo
    t = toc; fprintf('...done (%.2f sec).\n',t);
    fprintf('\n');
  end
  
end

%%-------------------------------------------------------------------------
function txt=obj2json(name,item,level,varargin)

if(iscell(item))
  txt=cell2json(name,item,level,varargin{:});
elseif(isstruct(item))
  txt=struct2json(name,item,level,varargin{:});
elseif(ischar(item))
  txt=str2json(name,item,level,varargin{:});
else
  txt=mat2json(name,item,level,varargin{:});
end

%%-------------------------------------------------------------------------
function txt=cell2json(name,item,level,varargin)
txt='';
if(~iscell(item))
  error('input is not a cell');
end

dim=size(item);
len=numel(item); % let's handle 1D cell first
padding1=repmat(sprintf('\t'),1,level-1);
padding0=repmat(sprintf('\t'),1,level);
if(len>1)
  if(~isempty(name))
    txt=sprintf('%s"%s": [\n',padding0, checkname(name,varargin{:})); name='';
  else
    txt=sprintf('%s[\n',padding0);
  end
elseif(len==0)
  if(~isempty(name))
    txt=sprintf('%s"%s": null',padding0, checkname(name,varargin{:})); name='';
  else
    txt=sprintf('%snull',padding0);
  end
end
for i=1:len
  txt=sprintf('%s%s%s',txt,padding1,obj2json(name,item{i},level+(len>1),varargin{:}));
  if(i<len) txt=sprintf('%s%s',txt,sprintf(',\n')); end
end
if(len>1) txt=sprintf('%s\n%s]',txt,padding0); end

%%-------------------------------------------------------------------------
function txt=struct2json(name,item,level,varargin)
txt='';
if(~isstruct(item))
  error('input is not a struct');
end
len=numel(item);
padding1=repmat(sprintf('\t'),1,level-1);
padding0=repmat(sprintf('\t'),1,level);
sep=',';

if(~isempty(name))
  if(len>1) txt=sprintf('%s"%s": [\n',padding0,checkname(name,varargin{:})); end
else
  if(len>1) txt=sprintf('%s[\n',padding0); end
end
for e=1:len
  names = fieldnames(item(e));
  if(~isempty(name) && len==1)
    txt=sprintf('%s%s"%s": {\n',txt,repmat(sprintf('\t'),1,level+(len>1)), checkname(name,varargin{:}));
  else
    txt=sprintf('%s%s{\n',txt,repmat(sprintf('\t'),1,level+(len>1)));
  end
  if(~isempty(names))
    for i=1:length(names)
      txt=sprintf('%s%s',txt,obj2json(names{i},getfield(item(e),...
        names{i}),level+1+(len>1),varargin{:}));
      if(i<length(names)) txt=sprintf('%s%s',txt,','); end
      txt=sprintf('%s%s',txt,sprintf('\n'));
    end
  end
  txt=sprintf('%s%s}',txt,repmat(sprintf('\t'),1,level+(len>1)));
  if(e==len) sep=''; end
  if(e<len) txt=sprintf('%s%s',txt,sprintf(',\n')); end
end
if(len>1) txt=sprintf('%s\n%s]',txt,padding0); end

%%-------------------------------------------------------------------------
function txt=str2json(name,item,level,varargin)
txt='';
if(~ischar(item))
  error('input is not a string');
end
item=reshape(item, max(size(item),[1 0]));
len=size(item,1);
sep=sprintf(',\n');

padding1=repmat(sprintf('\t'),1,level);
padding0=repmat(sprintf('\t'),1,level+1);

if(~isempty(name))
  if(len>1) txt=sprintf('%s"%s": [\n',padding1,checkname(name,varargin{:})); end
else
  if(len>1) txt=sprintf('%s[\n',padding1); end
end
isoct=jsonopt('IsOctave',0,varargin{:});
for e=1:len
  if(isoct)
    val=regexprep(item(e,:),'\\','\\');
    val=regexprep(val,'"','\"');
    val=regexprep(val,'^"','\"');
  else
    val=regexprep(item(e,:),'\\','\\\\');
    val=regexprep(val,'"','\\"');
    val=regexprep(val,'^"','\\"');
  end
  if(len==1)
    obj=['"' checkname(name,varargin{:}) '": ' '"',val,'"'];
    if(isempty(name)) obj=['"',val,'"']; end
    txt=sprintf('%s%s%s%s',txt,repmat(sprintf('\t'),1,level),obj);
  else
    txt=sprintf('%s%s%s%s',txt,repmat(sprintf('\t'),1,level+1),['"',val,'"']);
  end
  if(e==len) sep=''; end
  txt=sprintf('%s%s',txt,sep);
end
if(len>1) txt=sprintf('%s\n%s%s',txt,padding1,']'); end

%%-------------------------------------------------------------------------
function txt=mat2json(name,item,level,varargin)
if(~isnumeric(item) && ~islogical(item))
  error('input is not an array');
end

padding1=repmat(sprintf('\t'),1,level);
padding0=repmat(sprintf('\t'),1,level+1);

if(length(size(item))>2 || issparse(item) || ~isreal(item) || ...
    isempty(item) ||jsonopt('ArrayToStruct',0,varargin{:}))
  if(isempty(name))
    txt=sprintf('%s{\n%s"_ArrayType_": "%s",\n%s"_ArraySize_": %s,\n',...
      padding1,padding0,class(item),padding0,regexprep(mat2str(size(item)),'\s+',',') );
  else
    txt=sprintf('%s"%s": {\n%s"_ArrayType_": "%s",\n%s"_ArraySize_": %s,\n',...
      padding1,checkname(name,varargin{:}),padding0,class(item),padding0,regexprep(mat2str(size(item)),'\s+',',') );
  end
else
  if(isempty(name))
    txt=sprintf('%s%s',padding1,matdata2json(item,level+1,varargin{:}));
  else
    if(numel(item)==1 && jsonopt('NoRowBracket',1,varargin{:})==1)
      numtxt=regexprep(regexprep(matdata2json(item,level+1,varargin{:}),'^\[',''),']','');
      txt=sprintf('%s"%s": %s',padding1,checkname(name,varargin{:}),numtxt);
    else
      txt=sprintf('%s"%s": %s',padding1,checkname(name,varargin{:}),matdata2json(item,level+1,varargin{:}));
    end
  end
  return;
end
dataformat='%s%s%s%s%s';

if(issparse(item))
  [ix,iy]=find(item);
  data=full(item(find(item)));
  if(~isreal(item))
    data=[real(data(:)),imag(data(:))];
    if(size(item,1)==1)
      % Kludge to have data's 'transposedness' match item's.
      % (Necessary for complex row vector handling below.)
      data=data';
    end
    txt=sprintf(dataformat,txt,padding0,'"_ArrayIsComplex_": ','1', sprintf(',\n'));
  end
  txt=sprintf(dataformat,txt,padding0,'"_ArrayIsSparse_": ','1', sprintf(',\n'));
  if(size(item,1)==1)
    % Row vector, store only column indices.
    txt=sprintf(dataformat,txt,padding0,'"_ArrayData_": ',...
      matdata2json([iy(:),data'],level+2,varargin{:}), sprintf('\n'));
  elseif(size(item,2)==1)
    % Column vector, store only row indices.
    txt=sprintf(dataformat,txt,padding0,'"_ArrayData_": ',...
      matdata2json([ix,data],level+2,varargin{:}), sprintf('\n'));
  else
    % General case, store row and column indices.
    txt=sprintf(dataformat,txt,padding0,'"_ArrayData_": ',...
      matdata2json([ix,iy,data],level+2,varargin{:}), sprintf('\n'));
  end
else
  if(isreal(item))
    txt=sprintf(dataformat,txt,padding0,'"_ArrayData_": ',...
      matdata2json(item(:)',level+2,varargin{:}), sprintf('\n'));
  else
    txt=sprintf(dataformat,txt,padding0,'"_ArrayIsComplex_": ','1', sprintf(',\n'));
    txt=sprintf(dataformat,txt,padding0,'"_ArrayData_": ',...
      matdata2json([real(item(:)) imag(item(:))],level+2,varargin{:}), sprintf('\n'));
  end
end
txt=sprintf('%s%s%s',txt,padding1,'}');

%%-------------------------------------------------------------------------
function txt=matdata2json(mat,level,varargin)
if(size(mat,1)==1)
  pre='';
  post='';
  level=level-1;
else
  pre=sprintf('[\n');
  post=sprintf('\n%s]',repmat(sprintf('\t'),1,level-1));
end
if(isempty(mat))
  txt='null';
  return;
end
floatformat=jsonopt('FloatFormat','%.10g',varargin{:});
formatstr=['[' repmat([floatformat ','],1,size(mat,2)-1) [floatformat sprintf('],\n')]];

if(nargin>=2 && size(mat,1)>1 && jsonopt('ArrayIndent',1,varargin{:})==1)
  formatstr=[repmat(sprintf('\t'),1,level) formatstr];
end
txt=sprintf(formatstr,mat');
txt(end-1:end)=[];
if(islogical(mat) && jsonopt('ParseLogical',0,varargin{:})==1)
  txt=regexprep(txt,'1','true');
  txt=regexprep(txt,'0','false');
end
%txt=regexprep(mat2str(mat),'\s+',',');
%txt=regexprep(txt,';',sprintf('],\n['));
% if(nargin>=2 && size(mat,1)>1)
%     txt=regexprep(txt,'\[',[repmat(sprintf('\t'),1,level) '[']);
% end
txt=[pre txt post];
if(any(isinf(mat(:))))
  txt=regexprep(txt,'([-+]*)Inf',jsonopt('Inf','"$1_Inf_"',varargin{:}));
end
if(any(isnan(mat(:))))
  txt=regexprep(txt,'NaN',jsonopt('NaN','"_NaN_"',varargin{:}));
end

%%-------------------------------------------------------------------------
function newname=checkname(name,varargin)
isunpack=jsonopt('UnpackHex',1,varargin{:});
newname=name;
if(isempty(regexp(name,'0x([0-9a-fA-F]+)_','once')))
  return
end
if(isunpack)
  isoct=jsonopt('IsOctave',0,varargin{:});
  if(~isoct)
    newname=regexprep(name,'(^x|_){1}0x([0-9a-fA-F]+)_','${native2unicode(hex2dec($2))}');
  else
    pos=regexp(name,'(^x|_){1}0x([0-9a-fA-F]+)_','start');
    pend=regexp(name,'(^x|_){1}0x([0-9a-fA-F]+)_','end');
    if(isempty(pos)) return; end
    str0=name;
    pos0=[0 pend(:)' length(name)];
    newname='';
    for i=1:length(pos)
      newname=[newname str0(pos0(i)+1:pos(i)-1) char(hex2dec(str0(pos(i)+3:pend(i)-1)))];
    end
    if(pos(end)~=length(name))
      newname=[newname str0(pos0(end-1)+1:pos0(end))];
    end
  end
end

