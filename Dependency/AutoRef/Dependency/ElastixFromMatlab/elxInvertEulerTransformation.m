%% elxInvertEulerTransformation.m
% created by Mattijs Elschot 20150922
% inverts a transformation matrix (moving --> fixed to fixed --> moving)
%
% input:
% newFixedImage            - im3d structure;
% oldTransform              - cell containing the old ElastixFromMatlab transform;

% output:
% newTransform              - cell containing the inverted ElastixFromMatlab transform;
%


%% main function
function newTransform = elxInvertEulerTransformation(newFixedImage,oldTransform)


for ii=1:numel(oldTransform)
    
    % initialize counter for newTransform
    jj = numel(oldTransform)-ii+1;
    
    % check if Euler transform
    if not(strcmp(oldTransform{ii}.Transform,'EulerTransform'))
        error('script only defined for Euler transformations');
    end
    
    % initialize newTransform
    newTransform{jj} = oldTransform{ii};
    
    % switch some output type parameters
    newTransform{jj}.FixedImageDimension = oldTransform{ii}.MovingImageDimension;
    newTransform{jj}.MovingImageDimension = oldTransform{ii}.FixedImageDimension;
    newTransform{jj}.FixedInternalImagePixelType = oldTransform{ii}.MovingInternalImagePixelType;
    newTransform{jj}.MovingInternalImagePixelType = oldTransform{ii}.FixedInternalImagePixelType;
    
    % set new transform parameters
    newRotation = comp_decomp_matrix(transpose(comp_decomp_matrix(oldTransform{ii}.TransformParameters(1:3)')))';
    newTranslation = -transpose(comp_decomp_matrix(oldTransform{ii}.TransformParameters(1:3)'))*oldTransform{ii}.TransformParameters(4:6);
    newTransform{jj}.TransformParameters = [newRotation; newTranslation];
    
    % set new center of rotation
%     tmpCORP = newFixedImage.A*([((newTransform{jj}.Size)/2); 1.5]-0.5);
%     newTransform{jj}.CenterOfRotationPoint = tmpCORP(1:3);
    newTransform{jj}.CenterOfRotationPoint = comp_decomp_matrix(newRotation')*oldTransform{ii}.CenterOfRotationPoint - newTranslation;
    
    % set output geometry 
    if ii==1 % if first old transform (i.e. last new transform), use image info from new fixedImage to set output geometry.
        
        % set new size
        dims = size(newFixedImage.Data);
        newTransform{jj}.Size = [dims(2); dims(1); dims(3)];
        
        % set new spacing
        dRow = sqrt(sum(newFixedImage.A(:,1).^2));
        dCol = sqrt(sum(newFixedImage.A(:,2).^2));
        dSlc = sqrt(sum(newFixedImage.A(:,3).^2));
        newTransform{jj}.Spacing = [dCol dRow dSlc]';
        
        % set new origin
        newTransform{jj}.Origin = newFixedImage.A(1:3,4);
        
        % set new direction
        X = newFixedImage.A(1:3,1)./dCol;
        Y = newFixedImage.A(1:3,2)./dRow;
        Z = newFixedImage.A(1:3,3)./dSlc;
        newTransform{jj}.Direction = [X; Y; Z];
        
    else % otherwise, get info from previous transform to set output dimensions
        
        % set new size
        newTransform{jj}.Size = oldTransform{ii-1}.Size;
        
        % set new spacing
        newTransform{jj}.Spacing = oldTransform{ii-1}.Spacing;
        
        % set new origin
        newTransform{jj}.Origin = oldTransform{ii-1}.Origin;
        
        % set new direction
        newTransform{jj}.Direction = oldTransform{ii-1}.Direction;
        
        % set new center of rotation
%         newTransform{jj}.CenterOfRotationPoint = oldTransform{ii-1}.CenterOfRotationPoint;
              
    end
    
    % set initial transform
    if ii==numel(oldTransform) % if last old transform (i.e. first new transform), set no initial transform
    
        newTransform{jj}.InitialTransformParametersFileName = 'NoInitialTransform';
        
    else % set previous transform as initial transform
        
        newTransform{jj}.InitialTransformParametersFileName = strcat('TransformParameters.',num2str(jj-2),'.txt');
        
    end
        
   
end