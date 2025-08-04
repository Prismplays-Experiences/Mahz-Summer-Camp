local CFrameUtils = {}

function CFrameUtils.SetPosition(instance: Instance, position: Vector3)
	if (instance :: Model).PivotTo then
		(instance :: Model):PivotTo(CFrame.new(position))
	else
		(instance :: Part).Position = position
	end
end

function CFrameUtils.GetPosition(instance: Instance): Vector3
	local cframe = CFrameUtils.GetCframe(instance)

	return cframe.Position
end

function CFrameUtils.SetCframe(instance: Instance, cframe: CFrame)
	if (instance :: Model).PivotTo then
		(instance :: Model):PivotTo(cframe)
	else
		(instance :: Part).CFrame = cframe
	end
end

function CFrameUtils.GetCframe(instance: Instance): CFrame
	if (instance :: Model).PivotTo then
		return (instance :: Model):GetPivot()
	else
		return (instance :: Part).CFrame
	end
end


return CFrameUtils