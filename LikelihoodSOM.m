function [ANLL,LogLikelihood,Respon]=LikelihoodSOM(Modelo,TipoModelo,Muestras)
% Evaluar verosimilitudes asignadas por un mapa autoorganizado
% probabilístico
% Entradas:
% Modelo=Mapa probabilístico
% TipoModelo=Clase de mapa
%   'TSOM' (también vale para SOMN)
%   'KBTM'
%   'SOMM'
%   'MLTM'
%   'PPCASOM'
%   'tGTM'
%   'PGNG'
%   'PSOG'
% Muestras=Muestras a evaluar
% Salidas:
%   LogLikelihood=Logaritmos de las verosimilitudes log(p(t))
%   ANLL=Negativo de la media de LogLikelihood
%   Respon=Responsabilidades de las neuronas P(i | t)

[D,NumMuestras]=size(Muestras);
OtroModelo=1;
switch TipoModelo
    case 'PGNG'
        ActiveUnits=find(~isnan(Modelo.Means(1,:)));
        NumUnits=numel(ActiveUnits);
        NumFilasMapa=1;
        NumColsMapa=NumUnits;
        for NdxNeuro=1:NumUnits
            Medias{NdxNeuro}=Modelo.Means(:,ActiveUnits(NdxNeuro));
            C{NdxNeuro}=squeeze(Modelo.C(:,:,ActiveUnits(NdxNeuro)));
        end
        MiPi=ones(NumFilasMapa,NumColsMapa)/(NumFilasMapa*NumColsMapa);
    case 'PSOG'
        NumFilasMapa=1;
        NumColsMapa=Modelo.NumNeuronasGrafo;
        Medias=Modelo.Medias;
        C=Modelo.C;
        MiPi=ones(NumFilasMapa,NumColsMapa)/(NumFilasMapa*NumColsMapa);        
    case 'SOMN'
        NumFilasMapa=Modelo.NumFilasMapa;
        NumColsMapa=Modelo.NumColsMapa;
        Medias=Modelo.Medias;
        C=Modelo.C;
        MiPi=Modelo.Pi;
        
    case 'PbSOM'
        NumFilasMapa=Modelo.NumFilasMapa;
        NumColsMapa=Modelo.NumColsMapa;
        Medias=Modelo.Mu;
        C=Modelo.C;
        MiPi=ones(NumFilasMapa,NumColsMapa)/(NumFilasMapa*NumColsMapa);
        
    case 'KBTM'
        NumFilasMapa=Modelo.NumFilasMapa;
        NumColsMapa=Modelo.NumColsMapa;      
        Medias=Modelo.Medias;
        for NdxFila=1:NumFilasMapa
            for NdxCol=1:NumColsMapa
                C{NdxFila,NdxCol}=eye(D)*Modelo.Sigma{NdxFila,NdxCol};
            end
        end
        MiPi=ones(NumFilasMapa,NumColsMapa)/(NumFilasMapa*NumColsMapa);
        
    case 'MLTM'
        NumFilasMapa=Modelo.NumFilasMapa;
        NumColsMapa=Modelo.NumColsMapa;      
        Medias=Modelo.Mu;
        for NdxFila=1:NumFilasMapa
            for NdxCol=1:NumColsMapa
                C{NdxFila,NdxCol}=eye(D)*Modelo.Sigma2{NdxFila,NdxCol};
            end
        end
        MiPi=ones(NumFilasMapa,NumColsMapa)/(NumFilasMapa*NumColsMapa);
     
    case 'SOMM'
        NumFilasMapa=sqrt(size(Modelo.M,1));
        NumColsMapa=NumFilasMapa;
        NdxNeuro=1;
        for NdxFila=1:NumFilasMapa
            for NdxCol=1:NumColsMapa
                Medias{NdxFila,NdxCol}=Modelo.M(NdxNeuro,:)';
                C{NdxFila,NdxCol}=eye(D)*Modelo.SigmaS;
                NdxNeuro=NdxNeuro+1;
            end
        end
        MiPi=ones(NumFilasMapa,NumColsMapa)/(NumFilasMapa*NumColsMapa);
        
    case {'tGTM','GTM'}
        NumFilasMapa=Modelo.NumFilasMix;
        NumColsMapa=Modelo.NumColsMix;
        MiPi=ones(NumFilasMapa,NumColsMapa)/(NumFilasMapa*NumColsMapa);
        OtroModelo=0;
        
    case {'PPCASOM','TSOM'}
        NumFilasMapa=Modelo.NumFilasMapa;
        NumColsMapa=Modelo.NumColsMapa;
        MiPi=Modelo.Pi;
        OtroModelo=0;
        
    otherwise
        NumFilasMapa=Modelo.NumFilasMapa;
        NumColsMapa=Modelo.NumColsMapa;  
        MiPi=ones(NumFilasMapa,NumColsMapa)/(NumFilasMapa*NumColsMapa);
        OtroModelo=0;  
        
end


NumNeuro=NumFilasMapa*NumColsMapa;
LogLikelihood=zeros(NumMuestras,1);
Respon=zeros(NumMuestras,NumNeuro);

% PPCASOM
if strcmp(TipoModelo,'PPCASOM')
    for NdxNeuro=1:NumNeuro
        % Precalcular matrices relevantes
        q=size(Modelo.W{NdxNeuro},2);
        WInvWTW=Modelo.W{NdxNeuro}*inv(Modelo.W{NdxNeuro}'*Modelo.W{NdxNeuro});
        UqT=Modelo.Uq{NdxNeuro}';
        WT=Modelo.W{NdxNeuro}';
        MatrizDiagonal=diag(1./Modelo.Lambdaq{NdxNeuro});
        LogDetC=(D-q)*log(Modelo.Sigma2{NdxNeuro})+sum(log(Modelo.Lambdaq{NdxNeuro}));
        LogConstante=(-0.5*D)*log(2*pi)-0.5*LogDetC;
        for NdxMuestra=1:NumMuestras        
            VectorDif=Muestras(:,NdxMuestra)-Modelo.Medias{NdxNeuro};
            Tn=WInvWTW*(WT*VectorDif);
            Erec2=sum((VectorDif-Tn).^2);
            zin=UqT*VectorDif;
            Ein2=zin'*MatrizDiagonal*zin;
            En2=Ein2+Erec2/Modelo.Sigma2{NdxNeuro};
            Respon(NdxMuestra,NdxNeuro)=Modelo.Pi(NdxNeuro)*exp(LogConstante-0.5*En2);
        end
    end        
end

% TSOM
if strcmp(TipoModelo,'TSOM')
    for NdxNeuro=1:NumNeuro
        % Precalcular matrices relevantes
        LogDetC=log(det(Modelo.C{NdxNeuro}));
        LogConstante=gammaln(0.5*D+0.5*Modelo.Nu{NdxNeuro})-gammaln(0.5*Modelo.Nu{NdxNeuro}) ...
            -0.5*LogDetC-0.5*D*(1.144729885849400+log(Modelo.Nu{NdxNeuro}-2.0));
        Factor=-0.5*(D+Modelo.Nu{NdxNeuro});
        Factor2=1/(Modelo.Nu{NdxNeuro}-2.0);
        InvC=inv(Modelo.C{NdxNeuro});
        for NdxMuestra=1:NumMuestras        
            VectorDif=Muestras(:,NdxMuestra)-Modelo.Medias{NdxNeuro};
            DistMahal=VectorDif'*InvC*VectorDif;
            Respon(NdxMuestra,NdxNeuro)=Modelo.Pi(NdxNeuro)*...
                exp(LogConstante+Factor*log(1.0+Factor2*DistMahal));            
        end
    end
end

% t-GTM
if strcmp(TipoModelo,'tGTM')
    for NdxNeuro=1:Modelo.NumComponentesMixtura
        % Precalcular matrices relevantes
        VectorY=Modelo.W*Modelo.Phi(:,NdxNeuro);
        LogConstante=gammaln(0.5*Modelo.Nu+0.5*D)-0.5*D*log(Modelo.InvBeta) ...
            -gammaln(0.5*Modelo.Nu)-0.5*D*log(3.141592653589793*Modelo.Nu);
        Factor=-0.5*(Modelo.Nu+D);
        Factor2=1/(Modelo.InvBeta*Modelo.Nu);
        for NdxMuestra=1:NumMuestras        
            VectorDif=Muestras(:,NdxMuestra)-VectorY;
            NormaDiferencia=norm(VectorDif);
            Respon(NdxMuestra,NdxNeuro)=exp(LogConstante ...
                +Factor*log(1.0+Factor2*NormaDiferencia));                                
        end
    end
    Respon=Respon/Modelo.NumComponentesMixtura;
end

% GTM
if strcmp(TipoModelo,'GTM')
    for NdxNeuro=1:Modelo.NumComponentesMixtura
        % Precalcular matrices relevantes
        VectorY=Modelo.W*Modelo.Phi(:,NdxNeuro);
        LogConstante=0.5*D*log(0.159154943091895/Modelo.InvBeta);
        Factor=-0.5/Modelo.InvBeta;
        for NdxMuestra=1:NumMuestras        
            VectorDif=Muestras(:,NdxMuestra)-VectorY;
            NormaDiferencia=norm(VectorDif);
            Respon(NdxMuestra,NdxNeuro)=exp(LogConstante ...
                +Factor*NormaDiferencia);                                
        end
    end
    Respon=Respon/Modelo.NumComponentesMixtura;
end

% Otros modelos
if OtroModelo
    for NdxNeuro=1:NumNeuro
        % Precalcular matrices relevantes
        disp(C)
        disp(C{NdxNeuro})
        disp(inv(C{NdxNeuro}))
        disp(log(det(C{NdxNeuro})))
        pause(50)
        
        InvC=inv(C{NdxNeuro});
        LogDetC=log(det(C{NdxNeuro}));
        LogConstante=(-0.5*D)*log(2*pi)-0.5*LogDetC;
        for NdxMuestra=1:NumMuestras        
            VectorDif=Muestras(:,NdxMuestra)-Medias{NdxNeuro};
            DistMahal=VectorDif'*InvC*VectorDif;
            Respon(NdxMuestra,NdxNeuro)=MiPi(NdxNeuro)*...
                exp(LogConstante-0.5*DistMahal);
        end
    end        
end

% Depurar resultados y preparar salida
Respon(find(~isfinite(Respon)))=0;
for NdxMuestra=1:NumMuestras
    LogLikelihood(NdxMuestra)=log(sum(Respon(NdxMuestra,:)));
    Respon(NdxMuestra,:)=Respon(NdxMuestra,:)/sum(Respon(NdxMuestra,:));
end
ANLL=-mean(LogLikelihood(find(isfinite(LogLikelihood))));
    
   
        
            
        
            
        




