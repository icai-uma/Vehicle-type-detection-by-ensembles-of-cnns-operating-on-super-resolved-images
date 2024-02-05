function addVehicleType(trajectoryId,vehicleType)

params.MatlabProjectsDirectory = '../../../../proyectos_matlab/';
params.TrajectoryWithRepresentativeDirectory = strcat(params.MatlabProjectsDirectory,'coches/datosBlobs/trajectoriesWithRepresentative/');

infoFiles = dir(params.TrajectoryWithRepresentativeDirectory);

i=1;
found=0;

while i <= length(infoFiles) && found == 0
    if (infoFiles(i).isdir == 0)         
        filename = infoFiles(i).name;
        [pathstr, name, ext] = fileparts(filename);
        
        % Take only the .mat files
        if (strcmpi(ext,'.mat') == 1)
            path_mat = strcat(params.TrajectoryWithRepresentativeDirectory,filename);
            load(path_mat);
            disp(strcat(filename, ' file is computing...'));
            ndxTrajectoryId = find([kModel.SavedTrayectories.ID]==trajectoryId);
            if size(ndxTrajectoryId,2) == 1
                %disp(strcat('Trajectory ', num2str(trajectoryId), ' founded in file ', filename,'...')); 
                disp(sprintf('Trajectory %s founded in file %s in row %s...',num2str(trajectoryId),filename,num2str(ndxTrajectoryId)));
                Representative = kModel.SavedTrayectories(ndxTrajectoryId).Representative;
                
                Representative.DefinedVehicleType = vehicleType;
                kModel.SavedTrayectories(ndxTrajectoryId).Representative = Representative;
       
                save(path_mat,'kModel');
                disp(strcat(filename, ' file saved...'));
                found = 1;
            end
        end
    end
    i=i+1;
end
if i > length(infoFiles) && found == 0
    disp('Error: trajectoryId not found');
end




