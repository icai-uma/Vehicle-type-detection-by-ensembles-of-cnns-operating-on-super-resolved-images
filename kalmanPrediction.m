function kModel = kalmanPrediction(kModel)

for k=1:length(kModel.objects)

    obk = kModel.objects(k);
    
    % Predict the next state
    obk.xp = kModel.A*obk.x(end,:)';
    obk.xpred(size(obk.xpred,1)+1,:) = obk.xp;

    obk.PP = kModel.A*obk.P*kModel.A' + kModel.Q;

    kModel.objects(k) = obk;
end
  