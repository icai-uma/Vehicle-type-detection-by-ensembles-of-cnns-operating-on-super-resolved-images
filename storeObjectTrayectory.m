function kModel = storeObjectTrayectory(kModel, k)

obj = kModel.objects(k);

if ~isempty(kModel.SavedTrayectories)
    n = length(kModel.SavedTrayectories);
    if  n >= kModel.MaxSavedTrayectories
        save([kModel.path 'kModel_' num2str(kModel.LastFrame) '.mat'], 'kModel');
    
    %    kModel.SavedTrayectories = kModel.SavedTrayectories(2:end);
    %    n = length(kModel.SavedTrayectories);
        kModel.SavedTrayectories = obj;
    else
        kModel.SavedTrayectories(n+1) = obj;
    end
else
    kModel.SavedTrayectories = obj;
end