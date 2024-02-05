function Model = addEntryLogDistance(Model,NdxRow,NdxCol,SquaredDistance)

if isempty(Model.LogDistance{NdxRow,NdxCol})
    Model.LogDistance{NdxRow,NdxCol} = SquaredDistance;
else
    lon = length(Model.LogDistance{NdxRow,NdxCol});
    if lon >= Model.MaxLogDistance 
        Model.LogDistance{NdxRow,NdxCol} = Model.LogDistance{NdxRow,NdxCol}(2:end);
        lon = length(Model.LogDistance{NdxRow,NdxCol});
    end
    
    Model.LogDistance{NdxRow,NdxCol}(lon+1) = SquaredDistance;
end
